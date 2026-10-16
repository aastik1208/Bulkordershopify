class StoreFront::OrderUploadsController < StoreFront::BaseController

  before_action :fetch_shop, only: :create
  before_action :fetch_shopify_product_options, only: :download_sample_order_file

  def create
    @order_upload = @shop.store_front_order_uploads.build(new_order_upload_params)
    if @order_upload.save
      head :no_content
    else
      render_422
    end
  end

  def download_sample_order_file
    # @shopify_product_options = [[<option_position : str>,<option_name : str>], ..]
    send_data OrderUpload.sample_file_data(@shopify_product_options), filename: "sample-bulk-order-file.csv"
  end

  private

    def fetch_shop
      @shop = Shop.find_by(shopify_domain: params[:shop])
      unless @shop.present?
        render_404
      end
    end

    def new_order_upload_params
      params.require(:order_upload).permit(:source_email, :shopify_product_id, :file, :customer_name)
    end

    def fetch_shopify_product_options
      if params[:shopify_product_options].present?
        @shopify_product_options = params[:shopify_product_options].delete('["] ').split(',').collect { |element| element.split(':') }
      else
        render_422
      end
    end
end
