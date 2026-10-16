class AddCustomerNameToOrderUploads < ActiveRecord::Migration[5.1]
  def change
    add_column :order_uploads, :customer_name, :string
  end
end
