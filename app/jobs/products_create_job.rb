class ProductsCreateJob < ApplicationJob

  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)
    if shop.present?
      Product.create_new_shopify_product(webhook, shop)
    end
  end
end
