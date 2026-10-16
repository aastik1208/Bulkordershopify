require "csv"

class OrderUpload < ApplicationRecord

  ##CONCERNS
  include FileSampler

  ## CONSTANTS
  ERRORS_FILE_CONTENT_TYPE = 'text/plain'
  FILE_CONTENT_TYPES = ["text/plain", "text/csv", "application/csv", "application/x-csv", "text/comma-separated-values", "text/x-comma-separated-values", "text/tab-separated-values"]
  DEFAULT_STATUS = {
    pending: 0
  }
  FAILURE_STATUS = {
    failed_with_invalid_data: 1,
    failed_with_invalid_structure: 2
  }
  SUCCESS_STATUS = {
    successful: 3,
    successful_with_warning: 4,
    successful_with_error: 5,
    successful_with_warning_and_error: 6
  }
  STATUSES = DEFAULT_STATUS.merge(FAILURE_STATUS).merge(SUCCESS_STATUS)

  SOURCES = {
    admin_end: 0,
    store_front: 1
  }
  PER_PAGE_LIMIT = 10

  ##
  enum source: SOURCES
  enum status: STATUSES

  attr_accessor :errors_after_successful_upload, :warnings_after_successful_upload, :temp_errors_file, :note_attributes

  # ## ASSOCIATIONS
  belongs_to :shop
  has_attached_file :file
  has_attached_file :errors_file
  has_many :orders, dependent: :destroy

  ## VALIDATIONS
  validates :shopify_product_id, presence: true
  validate :ensure_shopify_product_exists, if: :shopify_product_id
  validates :source_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :source_email, presence: true
  validates :send_receipt, :notify_developer, inclusion: [true, false]
  validates_attachment :file, presence: true, content_type: { content_type: FILE_CONTENT_TYPES }
  validates_attachment :errors_file, content_type: { content_type: ERRORS_FILE_CONTENT_TYPE }

  ## CALLBACKS
  before_create :fetch_shopify_product_title, unless: :shopify_product_title
  after_commit :enqueue_read_file_job, on: :create, if: :pending?
  after_commit :re_enqueue_read_file_job, on: :update, if: [:pending?, :saved_change_to_file_file_name?]
  before_update :delete_errors_file, if: :file_file_name_changed?

  ## SCOPES
  scope :reverse_chronological_by_created_at, ->{ order(created_at: :desc) }


  def pretty_errors
    errors.full_messages.join('<br>')
  end

  def redact_customer_data(customer_email)
    redact_file_data(customer_email)
  end

  def read_file
    begin
      @file_data_array = CSV.read(file.path, {:encoding => 'ISO-8859-1'})
    rescue Exception => exception
      update(status: FAILURE_STATUS[:failed_with_invalid_structure])
    end
  end

  def ensure_file_validity
    if !pending?
      return
    end

    ensure_file_structure_validity
    if pending? && file_data_exists?
      ensure_file_data_valididity
    end
  end

  def send_invalid_file_email
    case status
    when 'failed_with_invalid_structure'
      send_invalid_file_structure_email
    when 'failed_with_invalid_data'
      send_invalid_file_data_email
    end
  end

  def send_successful_file_upload_email
    case status
    when 'successful'
      send_success_email
    when 'successful_with_warning'
      send_successful_with_warning_email
    when 'successful_with_error'
      send_successful_with_error_email
    when 'successful_with_warning_and_error'
      send_successful_with_warning_and_error_email
    end
  end

  def update_errors_after_successful_upload(error_message, order_index)
    case status
    when 'pending'
      update_issue_after_successful_upload('Error', order_index, error_message)
      update(status: SUCCESS_STATUS[:successful_with_error])
    when 'successful_with_warning'
      update_issue_after_successful_upload('Error', order_index, error_message)
      update(status: SUCCESS_STATUS[:successful_with_warning_and_error])
    when 'successful_with_error', 'successful_with_warning_and_error'
      update_issue_after_successful_upload('Error', order_index, error_message)
    end
  end

  def update_warnings_after_successful_order_upload(error_message, shopify_order_number)
    case status
    when 'pending'
      update_issue_after_successful_upload('Warning', shopify_order_number, error_message)
      update(status: SUCCESS_STATUS[:successful_with_warning])
    when 'successful_with_error'
      update_issue_after_successful_upload('Warning', shopify_order_number, error_message)
      update(status: SUCCESS_STATUS[:successful_with_warning_and_error])
    when 'successful_with_warning', 'successful_with_warning_and_error'
      update_issue_after_successful_upload('Warning', shopify_order_number, error_message)
    end
  end

  def open_temp_errors_file
    File.open(I18n.t(:errors_file_name, scope: :order_upload, file_file_name: file_file_name), 'a')
  end

  private

    def redact_file_data(customer_email)
      read_file
      updated_data = get_updated_data(customer_email)

      # write(no query is fired for this)
      begin
        CSV.open(file.path, 'w') do |csv|
          updated_data.each do |row|
            csv << row
          end
        end
      rescue Exception => exception
        raise ActiveRecord::Rollback
        send_customer_redaction_failure_email(customer_email)
      end
    end

    def get_updated_data(customer_email)
      initial_index = file_has_order_in_second_line? ? 1 : 2
      redact_this_order = false
      previous_order_index = nil

      # read
      updated_data = @file_data_array.select.with_index do |record, index|
        if initial_index > index
          return true
        else
          if previous_order_index.blank? || record[0] != previous_order_index
            redact_this_order = false
            previous_order_index = record[0]
            if record[1] == customer_email
              redact_this_order = true
              return false
            end
          elsif redact_this_order
            return false
          end
        end
        true
      end
      updated_data
    end

    def delete_errors_file
      if FAILURE_STATUS.keys.include? status.to_sym
        self.errors_file = nil
        self.status = 'pending'
        save
      else
        errors.add(:base, :cannot_update_non_failed_order_uploads, status: status)
        throw :abort
      end
    end

    def fetch_shopify_product_title
      # begin
        # shop.with_shopify_session do
          self.shopify_product_title = shop.products.find_by(shopify_id: shopify_product_id)&.shopify_title
        # end
      # rescue ActiveResource::ResourceNotFound => exception
      #   errors.add(:shopify_product_id, :invalid)
      # rescue Exception => exception
      #   Bugsnag.notify(exception)
      #   errors.add(:shopify_product_id, exception.message)
      # end
    end

    def file_data_exists?
      if (@file_data_array.length < 2 && file_has_order_in_second_line?) || (@file_data_array.length < 3 && !file_has_order_in_second_line?)
        @temp_errors_file = open_temp_errors_file
        @temp_errors_file.write("\n #{I18n.t(:file_has_no_order_data, scope: [:order_upload, :errors])}")
        self.status = FAILURE_STATUS[:failed_with_invalid_data]
        save_errors_file
        return false
      end
      true
    end

    def update_issue_after_successful_upload(issue_type, order_index_or_number, issue_message)
      case issue_type
      when 'Warning'
        @warnings_after_successful_upload ||= "\n\n\n" + I18n.t(:first_line , scope: [:order_upload, :errors, :warnings_after_successful_upload]) + "\n"
        @warnings_after_successful_upload += "\n" + I18n.t(:warning, scope: [:order_upload, :errors, :warnings_after_successful_upload], order_number: order_index_or_number, warning_message: issue_message)
      when 'Error'
        @errors_after_successful_upload ||= "\n\n\n" + I18n.t(:first_line , scope: [:order_upload, :errors, :errors_after_successful_upload]) + "\n"
        @errors_after_successful_upload += "\n" + I18n.t(:error, scope: [:order_upload, :errors, :errors_after_successful_upload], order_index: order_index_or_number, error_message: issue_message)
      end
    end

    def ensure_shopify_product_exists
      # begin
        # shop.with_shopify_session do

        # end
      unless shop.products.find_by(shopify_id: shopify_product_id)
        errors.add(:shopify_product_id, :invalid)
      # rescue Exception => exception
      #   Bugsnag.notify(exception)
      #   errors.add(:shopify_product_id, exception.message)
      end
    end

    def re_enqueue_read_file_job
      ReadOrderFileJob.perform_later(id)
    end

    def enqueue_read_file_job
      ReadOrderFileJob.perform_later(id)
    end

    def ensure_file_structure_validity
      if(file_first_line_invalid?)
        update(status: FAILURE_STATUS[:failed_with_invalid_structure])
      elsif @file_data_array[0].length > ORDER_UPLOAD_FILE_COLUMN_NAMES.length
        self.note_attributes = @file_data_array[0][ORDER_UPLOAD_FILE_COLUMN_NAMES.length..-1]
      end
    end

    def file_first_line_invalid?
      @file_data_array[0][0..ORDER_UPLOAD_FILE_COLUMN_NAMES.length-1] != ORDER_UPLOAD_FILE_COLUMN_NAMES
    end

    def file_has_order_in_second_line?
      @file_data_array[1][0].present?
    end

    def ensure_file_data_valididity
      @order = nil
      initial_index = file_has_order_in_second_line? ? 1 : 2

      @file_data_array[initial_index..@file_data_array.length-1].each_with_index do |record, index|

        build_order(record)

        if @line_item.first_order_line.present? && (@order.invalid? || @line_item.invalid? || @shipping_address.try(:invalid?))
          write_temp_errors_file(true, index, initial_index)
        elsif @line_item.first_order_line.blank? && (check_line_item_row_valid?(record) || @line_item.invalid?)
          write_temp_errors_file(false, index, initial_index)
        end
      end

      if @temp_errors_file.present?
        self.status = FAILURE_STATUS[:failed_with_invalid_data]
        orders.clear
        save_errors_file
      end
    end

    def check_line_item_row_valid?(record)
      shipping_address_fields_valid = shipping_address_corresponding_to_line_item_valid?(record[4..14])
      customer_email_field_valid = customer_email_corresponding_to_line_item_valid?(record[1])

      !(shipping_address_fields_valid && customer_email_field_valid)
    end

    def customer_email_corresponding_to_line_item_valid?(customer_email)
      if customer_email.present? && customer_email != @order.customer_email
        errors.add(:base, :customer_email_different_from_one_specified_initially)
        return false
      end
      true
    end

    def write_temp_errors_file(orders_first_line, index, initial_index)
      if orders_first_line
        @line_item.invalid?
        @shipping_address.try(:invalid?)
        current_line_errors = [@order.pretty_errors, @line_item.pretty_errors, @shipping_address.try(:pretty_errors), errors[:base].join(', ')].reject(&:blank?).join(', ')
      else
        @line_item.invalid?
        current_line_errors = [@line_item.pretty_errors, errors[:base].join(', ')].reject(&:blank?).join(', ')
        errors[:base].clear
      end

      @temp_errors_file ||= open_temp_errors_file
      @temp_errors_file.write("\nline-##{index + 1 + initial_index} - " + current_line_errors)
      @order.line_items.clear
    end

    def build_order(record)
      if @order.blank? || @order.order_index != record[0]
        @order = orders.build(order_index: record[0], customer_email: record[1], shopify_product_id: shopify_product_id)
        @shipping_address = nil
        if record[4..14].any?
          @shipping_address = @order.build_shipping_address(first_name: record[4], last_name: record[5], address_line_1: record[6], address_line_2: record[7], address_line_3: record[8], city: record[9], state: record[10], postal_code: record[11], country_code: record[12], company_name: record[13], phone: record[14])
        end
        if record[15..-1].any?
          attributes = {}
          self.note_attributes.each.with_index{|attr, i| attributes[attr] = record[15+i]}
          @order.assign_attributes(note_attributes: attributes)
        end
        @line_item = @order.line_items.build(first_order_line: true, variant_title: record[2], quantity: record[3])
      else
        @line_item = @order.line_items.build(variant_title: record[2], quantity: record[3])
      end
    end

    def shipping_address_corresponding_to_line_item_valid?(shipping_address_attribute_values)
      if shipping_address_attribute_values.any?
        if @shipping_address.present?
          saav = shipping_address_attribute_values
          temp_address = Address.new(first_name: saav[0], last_name: saav[1], address_line_1: saav[2], address_line_2: saav[3], address_line_3: saav[4], city: saav[5], state: saav[6], postal_code: saav[7], country_code: saav[8], company_name: saav[9], phone: saav[10])

          if @shipping_address.attributes.except('id', 'order_id', 'created_at', 'updated_at' ) != temp_address.attributes.except('id', 'order_id', 'created_at', 'updated_at')
            errors.add(:base, :shipping_address_different_from_one_specified_initially)
            return false
          end
        else
          errors.add(:base, :shipping_address_different_from_one_specified_initially)
          return false
        end
      end
      true
    end

    def save_errors_file
      @temp_errors_file.close
      @temp_errors_file = File.open(@temp_errors_file.path, 'r')
      update(errors_file: @temp_errors_file)
      File.delete(@temp_errors_file.path)
    end

    def send_invalid_file_structure_email
      OrderUploadMailer.invalid_file_structure_email(id).deliver_later
    end

    def send_invalid_file_data_email
      OrderUploadMailer.invalid_file_data_email(id).deliver_later
    end

    def send_success_email
      OrderUploadMailer.success_email(id).deliver_later
    end

    def send_successful_with_warning_email
      OrderUploadMailer.successful_with_warning_email(id).deliver_later
    end

    def send_successful_with_error_email
      OrderUploadMailer.successful_with_error_email(id).deliver_later
      if notify_developer?
        ApiFailureMailer.order_upload_successful_with_error_email(id).deliver_later
      end
    end

    def send_successful_with_warning_and_error_email
      OrderUploadMailer.successful_with_warning_and_error_email(id).deliver_later
      if notify_developer?
        ApiFailureMailer.order_upload_successful_with_warning_and_error_email(id).deliver_later
      end
    end

    def send_customer_redaction_failure_email(customer_email)
      DevelopersMailer.customer_redaction_failure_email(customer_email)
    end
end
