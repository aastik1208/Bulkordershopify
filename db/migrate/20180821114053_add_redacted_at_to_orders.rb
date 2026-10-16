class AddRedactedAtToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :redacted_at, :datetime
  end
end
