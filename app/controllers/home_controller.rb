class HomeController < ApplicationController

  before_action :reset_pagination_if_required, only: :index
  before_action :get_ransack_param, only: :index
  before_action :get_selected_tab_value, only: :index
  before_action :get_shopify_product_filter_options, only: :index

  def index
    @q = current_shop.order_uploads.ransack(@ransack_param)

    if params[:q].present?
      @admin_end_order_uploads = @q.result
      @store_front_order_uploads = @q.result
    else
      @admin_end_order_uploads = current_shop.order_uploads
      @store_front_order_uploads = current_shop.order_uploads
    end   
     @admin_end_order_uploads = @admin_end_order_uploads.admin_end.reverse_chronological_by_created_at.paginate(page: params[:admin_end_page], per_page: OrderUpload::PER_PAGE_LIMIT)
     @store_front_order_uploads = @store_front_order_uploads.store_front.reverse_chronological_by_created_at.paginate(page: params[:store_front_page], per_page: OrderUpload::PER_PAGE_LIMIT)
  end

  private

    def reset_pagination_if_required
      if params[:reset_pagination].present?
        params[:admin_end_page] = params[:store_front_page] = '1'
      end
    end

    def get_ransack_param
      if params[:q].present? && params[:q][:source_email_cont].present?
        params[:q][:source_email_cont].strip!
      end
      @ransack_param = params[:q]
    end

    def get_selected_tab_value
      @selected_tab_value = params[:selected_tab]
    end

    def get_shopify_product_filter_options
      @shopify_product_options = current_shop.order_uploads.distinct(:shopify_product_id).pluck(:shopify_product_title, :shopify_product_id)
    end
end
