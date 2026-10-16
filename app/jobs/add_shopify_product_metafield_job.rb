class AddShopifyProductMetafieldJob < ApplicationJob

  def perform(product_id)
    product = Product.find_by(id: product_id)

    if product.present?
      product.add_shopify_bulk_order_metafield
    end
  end
end
