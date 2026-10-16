class OrderUploadMailer < ApplicationMailer

  def invalid_file_structure_email(order_upload_id)
    send_mail(order_upload_id)
  end

  def invalid_file_data_email(order_upload_id)
    send_mail(order_upload_id)
  end

  def success_email(order_upload_id)
    send_mail(order_upload_id)
  end

  def successful_with_warning_email(order_upload_id)
    send_mail(order_upload_id)
  end

  def successful_with_error_email(order_upload_id)
    send_mail(order_upload_id)
  end

  def successful_with_warning_and_error_email(order_upload_id)
    send_mail(order_upload_id)
  end

  private

    def send_mail(order_upload_id)
      @order_upload = OrderUpload.find_by id: order_upload_id

      if @order_upload.present?
        @shop = @order_upload.shop
        @customer_name = @order_upload.customer_name || 'Customer'

        if @order_upload.errors_file.exists?
          case @order_upload.status
          when 'failed_with_invalid_data'
            attachment_name = "#{@order_upload.file_file_name}-data-errors.txt"
          when 'successful_with_error'
            attachment_name = "#{@order_upload.file_file_name}-data-errors.txt"
          when 'successful_with_warning'
            attachment_name = "#{@order_upload.file_file_name}-data-warnings.txt"
          when 'successful_with_warning_and_error'
            attachment_name = "#{@order_upload.file_file_name}-data-warning_and_errors.txt"
          end
          attachments[attachment_name] = File.read(@order_upload.errors_file.path)
        end

        mail(to: @order_upload.source_email, cc: @shop.contact_emails, subject: default_i18n_subject(file_name: @order_upload.file_file_name))
      end
    end
end
