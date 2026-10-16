class AssociatedOrdersCreationService

  attr_accessor :order_upload

  def initialize(order_upload_object)
    @order_upload = order_upload_object
  end

  def save_associated_orders
    if order_upload.save
      case order_upload.status
      when 'pending'
        order_upload.update(status: OrderUpload::SUCCESS_STATUS[:successful])
      when 'successful_with_warning', 'successful_with_error', 'successful_with_warning_and_error'
        save_errors_file_after_successful_upload
      end
    end
  end

  def save_errors_file_after_successful_upload
    order_upload.temp_errors_file = order_upload.open_temp_errors_file
    order_upload.temp_errors_file.write(order_upload.errors_after_successful_upload.to_s + order_upload.warnings_after_successful_upload.to_s)
    order_upload.temp_errors_file.close

    order_upload.temp_errors_file = File.open(order_upload.temp_errors_file.path, 'r')
    order_upload.update(errors_file: order_upload.temp_errors_file)
    File.delete(order_upload.temp_errors_file.path)
  end
end
