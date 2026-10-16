# class ProductsUpdateTitleJob < ActiveJob::Base
#   def perform(shop_domain:, webhook:)
#     shop = Shop.find_by(shopify_domain: shop_domain)
#     product = Product.find_by(shopify_id: webhook[:id])

#     if product.present? && product_title_changed?(product, webhook[:title])
#       product.update(shopify_title: webhook[:title])
#     end
#   end

#   private

#     def product_title_changed?(product, shopify_title)
#       product.shopify_title != shopify_title
#     end
# end
class ProductsUpdateJob < ApplicationJob

  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)
    if shop.present?
      product = shop.products.find_by(shopify_id: webhook[:id])
      if product.present?
        product.update_products_data(webhook, shop)
      end
    end
  end

end
