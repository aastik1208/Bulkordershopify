class CreateOrderUploads < ActiveRecord::Migration[5.1]
  def change
    create_table :order_uploads do |t|
      t.integer :source, default: 0
      t.string :source_email
      t.integer :status, default: 0
      t.boolean :send_receipt, default: true
      t.references :shop, foreign_key: true
      t.bigint :shopify_product_id
      t.string :shopify_product_title
      t.boolean :notify_developer, default: false

      t.timestamps
    end

    add_attachment :order_uploads, :file
    add_attachment :order_uploads, :errors_file
  end
end
