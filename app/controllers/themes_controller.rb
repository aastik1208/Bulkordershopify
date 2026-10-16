class ThemesController < ApplicationController

  # before_action :get_previously_selected_products, only: [:edit_selected_products, :update_selected_products, :get_shopify_products_options]
  # before_action :get_previously_selected_products_shopify_ids, only: [:edit_selected_products, :update_selected_products, :get_shopify_products_options]

  def edit
  end

  def update
    current_shop.enqueue_modify_theme_job
    flash[:notice] = I18n.t(:theme_successfully_modified, scope: [:flash, :notice])
    redirect_to root_path
  end

  def download_product_bulk_order_file
    send_file(current_shop.class::APP_PRODUCT_BULK_ORDER_SECTION_FILE_PATH.to_s)
  end

  def theme_modification_removal_instructions
    send_file(current_shop.class::THEME_MODIFICATION_REMOVAL_INSTRUCTION_FILE_PATH.to_s, filename: 'theme_modification_removal_instructions.txt')
  end

  def edit_selected_products
    @all_products = current_shop.products.collect { |product| [product.shopify_title, product.shopify_id] }
    @previously_selected_products_shopify_ids = current_shop.products.where(store_front_form: true).pluck(:shopify_id)
  end

  def update_selected_products
    selected_products_shopify_ids = params[:bulk_order][:select_products].reject(&:blank?).map(&:to_i)
    @previously_selected_products_shopify_ids = current_shop.products.where(store_front_form: true).pluck(:shopify_id)
    new_selected_products_shopify_ids = selected_products_shopify_ids - @previously_selected_products_shopify_ids
    to_remove_products_shopify_ids = @previously_selected_products_shopify_ids - selected_products_shopify_ids

    # build_new_associated_products(new_selected_products_shopify_ids)
    # mark_to_remove_products_for_destruction(to_remove_products_shopify_ids)
    current_shop.products.where(shopify_id: to_remove_products_shopify_ids).update(store_front_form: false)
    current_shop.products.where(shopify_id: new_selected_products_shopify_ids).update(store_front_form: true)

    # if current_shop.save
    flash[:notice] = I18n.t(:products_successfully_selected, scope: [:flash, :notice])
    redirect_to edit_themes_path
    # else
    #   flash[:shopify_error] = I18n.t(:product_selection_failed, scope: [:flash, :shopify_errors])
    #   redirect_to edit_selected_products_themes_path
    # end
  end

  # def get_shopify_products_options
  #   begin
  #     shopify_products = ShopifyAPI::Product.find(:all)
  #     options = shopify_products.collect { |shopify_product| [shopify_product.title, shopify_product.id] }
  #     render json: { options: options.to_h, selected_values: @previously_selected_products_shopify_ids }
  #   rescue Exception => exception
  #     Bugsnag.notify(exception)
  #     ApiFailureMailer.forms_product_selection_failure_email(shop.id)
  #     render json: { error: I18n.t(:api_error_fetching_shopify_products, scope: :product) }, status: 422
  #   end
  # end

  private

    # def get_previously_selected_products
    #   @previously_selected_products = current_shop.products.where(store_front_form: true)
    # end

    # def get_previously_selected_products_shopify_ids
    #   @previously_selected_products_shopify_ids = @previously_selected_products.pluck(:shopify_id)
    # end

    # def build_new_associated_products(shopify_product_ids)
    #   new_products = []
    #   shopify_product_ids.each do |shopify_product_id|
    #     new_products << { shopify_id: shopify_product_id }
    #   end
    #   current_shop.products.build(new_products);
    # end

    # def mark_to_remove_products_for_destruction(shopify_product_ids)
    #   if shopify_product_ids.any?
    #     current_shop.products.each do |product|
    #       if shopify_product_ids.include? product.shopify_id
    #         product.mark_for_destruction
    #       end
    #     end
    #   end
    # end

end
