class ProductsDeleteJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)
    product = Product.find_by(shopify_id: webhook[:id])

    if product.present?
      # product.update(store_front_form: false)
      product.destroy
    end
  end
end
