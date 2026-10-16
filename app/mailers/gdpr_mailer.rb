class GdprMailer < ApplicationMailer

  def send_customers_data_email(shop_id, order_csv_file_path, customer_email)
    @shop = Shop.find_by(id: shop_id)
    @customer_email = customer_email
    
    if @shop.present?
      attachments["#{customer_email}_order.csv"] = File.read(order_csv_file_path)
      File.delete(order_csv_file_path)

      mail(to: @shop.shopify_email, subject: default_i18n_subject(customer_email: customer_email))
    end
  end

end
