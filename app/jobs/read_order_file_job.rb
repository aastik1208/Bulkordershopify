class ReadOrderFileJob < ApplicationJob

  def perform(order_upload_id)
    order_upload = OrderUpload.find_by(id: order_upload_id) 
   
    if order_upload.present?
      order_upload.read_file
      order_upload.ensure_file_validity

      order_upload_status = order_upload.status

      if order_upload.failed_with_invalid_data? || order_upload.failed_with_invalid_structure?
        order_upload.send_invalid_file_email
      else
        AssociatedOrdersCreationService.new(order_upload).save_associated_orders
        if OrderUpload::SUCCESS_STATUS.keys.include? order_upload.status.to_sym
          order_upload.send_successful_file_upload_email
        end
      end
    end
  end
end
