require 'csv'

class Order < ApplicationRecord

  delegate :shop, to: :order_upload
  attr_accessor :order_index

  ## CONSTANTS
  ORDER_INDEX_MINIMUM_VALUE = 1

  ## ASSOCIATION
  belongs_to :order_upload
  has_many :line_items, dependent: :destroy, validate: false
  has_many :addresses, dependent: :destroy, validate: false
  has_one :shipping_address, -> { where(category: 'shipping') }, class_name: 'Address'

  ## VALIDATIONS
  with_options presence: true do
    validates :shopify_product_id
    validates :customer_email, unless: :redacted_at
    validates :order_index, numericality: {
      only_integer: true,
      greater_than_or_equal_to: ORDER_INDEX_MINIMUM_VALUE,
      allow_nil: true
    }
  end
  validates :customer_email, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: :redacted_at

  ## CALLBACKS
  after_create :create_shopify_order, if: :has_line_items?, unless: :shopify_order_id


  def self.generate_csv(shop, customer_email, shopify_ids_array)
    orders = shop.orders.where(customer_email: customer_email).or(Order.where(shopify_order_id: shopify_ids_array)).includes(:order_upload, :line_items, :shipping_address)
    csv_file_path = Rails.root.join("tmp/#{customer_email}_order.csv")

    CSV.open(csv_file_path, 'w') do |csv|
      csv << ['name', 'email', 'first_name', 'last_name', 'address1', 'address2', 'address3', 'city', 'state_name', 'country_code', 'line_item_name', 'line_item_quantity']
      orders.each do |order|
        order.line_items.each do |line_item|
          csv << [order.shopify_name, order.customer_email, order.first_name, order.last_name, order.shipping_address.address1, order.shipping_address.address2, order.shipping_address.address3, order.shipping_address.city, order.shipping_address.state, order.shipping_address.country_code, order.order_upload.product_title, line_item.quantity]
        end
      end
    end

    csv_file_path
  end

  def pretty_errors
    errors.full_messages.join(", ")
  end

  def redact_customer_data
    ActiveRecord::Base.transation do
      order_upload.redact_customer_data(customer_email)
      update(customer_email: nil, redacted_at: Time.current)
      addresses.destroy_all
    end
  end

  private

    def has_line_items?
      line_items.any?
    end

    def create_shopify_order
      ShopifyOrderCreationService.new(self).create_shopify_order
    end
end
