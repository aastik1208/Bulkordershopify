class ApiFailureMailer < ApplicationMailer
  default to: Rails.application.secrets.developer_email

  def order_upload_successful_with_error_email(order_upload_id)
    send_order_upload_failure_mail(order_upload_id)
  end

  def order_upload_successful_with_warning_and_error_email(order_upload_id)
    send_order_upload_failure_mail(order_upload_id)
  end

  def shop_theme_modification_failure_email(shop_id)
    theme_modification_failure_mail(shop_id)
  end

  def forms_product_selection_failure_email(shop_id)
    theme_modification_failure_mail(shop_id)
  end

  private

    def send_order_upload_failure_mail(order_upload_id)
      @order_upload = OrderUpload.find_by id: order_upload_id

      if @order_upload.present?
        @shop = @order_upload.shop
        attachments["#{@order_upload.file_file_name}-data-errors.txt"] = File.read(@order_upload.errors_file.path)
        mail(subject: default_i18n_subject(file_name: @order_upload.file_file_name, shop_domain: @shop.shopify_domain))
      end
    end

    def theme_modification_failure_mail(shop_id)
      @shop = Shop.find_by(id: shop_id)

      if @shop.present?
        mail(subject: default_i18n_subject(shop_domain: @shop.shopify_domain))
      end
    end

end
