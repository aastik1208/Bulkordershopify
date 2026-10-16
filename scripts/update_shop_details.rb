Shop.all.each do |shop|
  shop.with_shopify_session do
    shop_details = ShopifyAPI::Shop.current
    shop.update_columns(shopify_owner: shop_details.shop_owner)
  end
end
