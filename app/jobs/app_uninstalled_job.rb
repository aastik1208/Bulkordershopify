class AppUninstalledJob < ApplicationJob
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    destory_shop_and_its_associated_data(shop)
  end

  def destory_shop_and_its_associated_data(shop)
    shop.destroy
  end
end
