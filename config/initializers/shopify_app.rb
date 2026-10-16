ShopifyApp.configure do |config|
  config.application_name = 'Bulk Order Upload'
  config.api_key = Rails.application.secrets.shopify_application_api_key
  config.secret = Rails.application.secrets.shopify_application_secret
  config.scope = "read_orders, write_orders, read_products, write_products, read_themes, write_themes"
  config.embedded_app = true
  config.enable_same_site_none = true
  config.after_authenticate_job = false
  config.api_version = '2022-07'
  config.shop_session_repository = Shop
  config.webhooks = [
    {topic: 'app/uninstalled', address: Rails.application.secrets.app_host_address + '/webhooks/app_uninstalled', format: 'json'},
    {topic: 'products/delete', address: Rails.application.secrets.app_host_address + '/webhooks/products_delete', format: 'json'},
    {topic: 'products/update', address: Rails.application.secrets.app_host_address + '/webhooks/products_update', format: 'json'},
    {topic: 'products/create', address: Rails.application.secrets.app_host_address + '/webhooks/products_create', format: 'json'},
    {topic: 'shop/update', address: Rails.application.secrets.app_host_address + '/webhooks/shop_update', format: 'json'},
  ]
end
