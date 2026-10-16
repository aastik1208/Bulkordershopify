class AddShopifyNameToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :shopify_name, :string
  end
end
