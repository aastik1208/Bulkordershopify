class RenameColumnsOfAddresses < ActiveRecord::Migration[5.1]
  def change
    change_table :addresses do |t|
      t.rename :zip, :postal_code
      t.rename :company, :company_name
      t.rename :province, :state
    end
  end
end
