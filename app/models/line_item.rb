class LineItem < ApplicationRecord

  delegate :shop, to: :order
  attr_accessor :first_order_line

  ## CONSTANTS
  QUANTITY_MINIMUM_VALUE = 1

  ## ASSOCATIONS
  belongs_to :order

  ## VALIDATIONS
  with_options presence: true do
    validates :quantity, numericality: {
      only_integer: true,
      greater_than_or_equal_to: QUANTITY_MINIMUM_VALUE,
      allow_nil: true
    }
  end
  validate :ensure_variant_exists

  ## CALLBACKS
  before_validation :format_variant_title
  before_create :fetch_shopify_variant_id, unless: :shopify_variant_id

  def pretty_errors
    errors.full_messages.join(", ")
  end

  private

    def format_variant_title
      self.variant_title = variant_title&.split(VARIANT_TITLE_SEPERATOR)&.join(' / ')
    end

    def shopify_variant
      @shopify_variant ||= find_shopify_variant
    end

    def find_shopify_variant
      # begin
        # shop.with_shopify_session do
          variants = shop.products.find_by(shopify_id: order.shopify_product_id).variants
          if variant_title.present?
            variants.detect{ |shopify_variant| shopify_variant.shopify_title == variant_title }
          elsif variants.length == 1
            variants.first
          end
        # end
      # rescue ActiveResource::ResourceNotFound => exception
      #   nil
      # end
    end

    def ensure_variant_exists
      if shopify_variant.blank?
        errors.add(:variant_title, :invalid)
      end
    end

    def fetch_shopify_variant_id
      self.shopify_variant_id = shopify_variant.shopify_id
    end
end
