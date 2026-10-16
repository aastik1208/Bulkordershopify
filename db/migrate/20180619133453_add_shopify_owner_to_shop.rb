class AddShopifyOwnerToShop < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :shopify_owner, :string
  end
end
