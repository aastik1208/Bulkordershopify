# class FetchShopifyProductTitleJob < ApplicationJob

#   def perform(product_id)
#     product = Product.find_by(id: product_id)

#     if product.present?
#       product.fetch_shopify_title
#     end
#   end
# end

class CreateShopifyOrderJob < ApplicationJob

  def perform(order_id)
    order = Order.find_by(id: order_id)

    if order.present?
      order.create_shopify_order
    end
  end
end