class OrderUploadsController < ApplicationController

  before_action :fetch_shopify_product, only: :download_sample_order_file
  before_action :ensure_params_exists, only: :update
  before_action :get_order_upload, only: :update

  def new
    @order_upload = current_shop.order_uploads.build(source_email: current_shop.shopify_email)
    get_all_shopify_products
  end

  def create
    @order_upload = current_shop.order_uploads.build(new_order_upload_params.merge(customer_name: current_shop.shopify_owner))
    if @order_upload.save
      flash[:notice] = I18n.t(:bulk_order_file_successfully_upload, scope: [:flash, :notice])
      redirect_to root_path
    else
      get_all_shopify_products
      render :new
    end
  end

  def update
    if @order_upload.update(edit_order_upload_params)
      flash[:notice] = I18n.t(:bulk_order_successfully_updated, scope: [:flash, :notice])
    else
      get_all_shopify_products
      flash[:shopify_error] = @order_upload.pretty_errors
    end
    redirect_to root_path
  end

  def download_sample_order_file
    # shopify_product_options = [[<option_position : int>,<option_name : str>], ..]
    shopify_product_options = @shopify_product.options.collect { |option| [option.position, option.name] }
    send_data OrderUpload.sample_file_data(shopify_product_options), filename: "sample-order-file-#{@shopify_product.title}.csv", disposition: 'attachment'
  end

  private

    def new_order_upload_params
      params.require(:order_upload).permit(:source_email, :shopify_product_id, :file, :send_receipt)
    end

    def ensure_params_exists
      unless params.has_key? 'order_upload'
        flash[:shopify_error] = I18n.t(:no_file_was_selected, scope: [:flash, :shopify_error])
        redirect_to root_path and return
      end
    end

    def edit_order_upload_params
      params.require(:order_upload).permit(:file)
    end

    def get_order_upload
      @order_upload = current_shop.order_uploads.find_by(id: params[:id])
      if @order_upload.blank?
        render_404
      end
    end

    def get_all_shopify_products
      # begin
        @shopify_products = current_shop.products
      # rescue Exception => exception
      #   Bugsnag.notify(exception)
      #   flash[:shopify_error] = exception.message
      #   redirect_to root_path and return
      # end
    end

    def fetch_shopify_product
      if params[:selected_shopify_product_id].present?
        begin
          @shopify_product = ShopifyAPI::Product.find(params[:selected_shopify_product_id])
        rescue ActiveResource::ResourceNotFound => exception
          Bugsnag.notify(exception)
          flash[:shopify_error] = I18n.t(:invalid_product_selected, scope: [:flash, :error])
          redirect_to new_order_upload_path and return
        rescue Exception => exception
          Bugsnag.notify(exception)
          flash[:shopify_error] = exception.message
          redirect_to new_order_upload_path and return
        end

      else
        flash[:shopify_error] = I18n.t(:no_product_selected, scope: [:flash, :error])
        redirect_to new_order_upload_path and return
      end
    end
end
