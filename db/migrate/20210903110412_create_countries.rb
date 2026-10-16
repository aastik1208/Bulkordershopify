class CreateCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :countries do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.index [:name, :code]

      t.timestamps
    end
  end
end
