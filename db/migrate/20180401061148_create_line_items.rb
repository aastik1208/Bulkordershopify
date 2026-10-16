class CreateLineItems < ActiveRecord::Migration[5.1]
  def change
    create_table :line_items do |t|
      t.string :variant_title
      t.integer :quantity
      t.bigint :shopify_variant_id

      t.references :order, foreign_key: true

      t.timestamps
    end
  end
end
