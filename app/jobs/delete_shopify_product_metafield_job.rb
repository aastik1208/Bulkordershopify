class DeleteShopifyProductMetafieldJob < ApplicationJob

  def perform(shop_domain, shopify_product_id)
    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.present?
      begin
        shop.with_shopify_session do
          shopify_product = ShopifyAPI::Product.find(shopify_product_id)
          bulk_order_metafield =  shopify_product.metafields.detect{ |metafield| metafield.key == Product::BULK_ORDER_FORM_METAFIELD_KEY } 
        
          if bulk_order_metafield.present?
            bulk_order_metafield.destroy
          end
        end
      rescue Exception => exception
        Bugsnag.notify(exception)
        ApiFailureMailer.forms_product_selection_failure_email(shop.id)
      end
    end
  end
end
