class CustomersRedactJob < ApplicationJob
  def perform(shop_domain:, webhook:)
    temp = {type: 'customer_redact', shop_domain: shop_domain, webhook: webhook}
    Bugsnag.notify(temp);
    
    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.present?
      redact_customer_data(webhook)
    end
  end

  def redact_customer_data(webhook)
    @orders = Order.where(customer_email: webhook[:customer][:email]).or(Order.where(shopify_order_id: webhook[:orders_to_redact]))
    @orders.each do |order|
      order.redact_customer_data
    end
  end
end

