class ShopifyOrderCreationService

  SHOPIFY_NEW_ORDER_INVENTORY_BEHABIOUR = 'decrement_obeying_policy'
  SHOPIFY_NEW_ORDER_FINANCIAL_STATUS = 'paid'
  SHOPIFY_NEW_ORDER_FULLFILLMENT_STATUS = 'null'

  attr_accessor :order, :order_upload, :shop, :shipping_address

  def initialize(order_object)
    @order = order_object
    @order_upload = order.order_upload
    @shop = order_upload.shop
    @shipping_address = order.shipping_address
  end

  def create_shopify_order
    count = 0
    limit = 10
    begin
      count += 1
      shop.with_shopify_session do
        shopify_order = ShopifyAPI::Order.new(
                          email: order.customer_email,
                          inventory_behaviour: SHOPIFY_NEW_ORDER_INVENTORY_BEHABIOUR,
                          financial_status: SHOPIFY_NEW_ORDER_FINANCIAL_STATUS ,
                          fullfillment_status: SHOPIFY_NEW_ORDER_FULLFILLMENT_STATUS,
                          note_attributes: order.note_attributes.map{|key,value| {name: key, value: value}}.presence || [],
                          send_receipt: order_upload.send_receipt)
        shopify_line_items = []
        order.line_items.each do |line_item|
          shopify_line_items << { variant_id: line_item.shopify_variant_id, quantity: line_item.quantity }
        end
        shopify_order.line_items = shopify_line_items

        if shopify_order.save
          order.update_columns(shopify_order_id: shopify_order.id, shopify_name: shopify_order.name)
          create_shopify_shipping_address(shopify_order)
        else
          order_upload.update_errors_after_successful_upload(shopify_order.errors.full_messages.join(', '), order.order_index)
        end
      end
      Rails.logger.error('***************************test2**************************')
    rescue ActiveResource::ClientError => e
      if count >= limit || e.message != "Failed.  Response code = 429.  Response message = Too Many Requests."
        raise
      else
        sleep(count + 20)
        retry
      end

    rescue Exception => exception
      Bugsnag.notify(exception)
      order_upload.notify_developer = true
      order_upload.update_errors_after_successful_upload(exception.message, order.order_index)
    end
  end

  def create_shopify_shipping_address(shopify_order)
    if shipping_address.present?
      shop.with_shopify_session do
        shopify_order.shipping_address = {
          first_name: shipping_address.first_name,
          last_name: shipping_address.last_name,
          address1: shipping_address.address_line_1,
          address2: "#{shipping_address.address_line_2}" + ", #{shipping_address.address_line_3}",
          company: shipping_address.company_name,
          city: shipping_address.city,
          province: shipping_address.state,
          country_code: shipping_address.country_code,
          phone: shipping_address.phone,
          zip: shipping_address.postal_code }
        shopify_order.send_receipt = false

        unless shopify_order.save
          update_shopify_order_message_attribute_keys(shopify_order)
          order_upload.update_warnings_after_successful_order_upload(shopify_order.errors.full_messages.join(', '), shopify_order.name)
        end
      end
    end
  end

  def update_shopify_order_message_attribute_keys(shopify_order)
    shopify_order.errors[:shipping_address].each do |message|
      if message.include?('zip')
        message.gsub!(/zip/, 'postal_code')
      end
      if message.include?('province')
        message.gsub!(/province/, 'state')
      end
      if message.include?('company')
        message.gsub!(/company/, 'company_name')
      end
    end
  end
end
