class AddNoteAttributesToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :note_attributes, :jsonb, default: {}
  end
end
