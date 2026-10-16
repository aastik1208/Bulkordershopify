module FileSampler
  extend ActiveSupport::Concern

  class_methods do
    def sample_file_data(shopify_product_options)
      variant_title_format = shopify_product_options.sort.to_h.values.join(VARIANT_TITLE_SEPERATOR)
      sample_file_data_string(variant_title_format)
    end

    def sample_file_data_string(variant_title_format)
      order_upload_file_column_names_string = ORDER_UPLOAD_FILE_COLUMN_NAMES.join(',')
      order_upload_file_column_names_string + "\n,,#{variant_title_format}"  
    end
  end

end
