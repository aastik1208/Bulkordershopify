class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.string :first_name
      t.string :last_name
      t.string :address_line_1
      t.string :address_line_2
      t.string :address_line_3
      t.string :city
      t.string :province
      t.string :zip
      t.string :country_code
      t.string :company
      t.integer :category, default: 0

      t.references :order, foreign_key: true

      t.timestamps
    end
  end
end
