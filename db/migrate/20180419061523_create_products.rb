class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.bigint :shopify_id
      t.string :shopify_title
      t.references :shop
      t.boolean :store_front_form

      t.index [:shopify_id, :shop_id], unique: true

      t.timestamps
    end
  end
end
