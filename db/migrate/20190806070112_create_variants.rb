class CreateVariants < ActiveRecord::Migration[5.1]
  def change
    create_table :variants do |t|

      t.string :shopify_id
      t.string :shopify_title
      t.references :product

      t.timestamps null: false
    end
  end
end
