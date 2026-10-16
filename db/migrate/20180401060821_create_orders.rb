class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.bigint :shopify_product_id
      t.bigint :shopify_order_id
      t.string :customer_email
      t.bigint :shopify_product_id

      t.references :order_upload, foreign_key: true

      t.timestamps
    end
  end
end
