class AddContactEmailsToShops < ActiveRecord::Migration[5.1]
  def change
    add_column :shops, :contact_emails, :string, default: 'webstores@socialimprints.com'
  end
end
