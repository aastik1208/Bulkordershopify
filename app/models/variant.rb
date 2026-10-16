class Variant < ApplicationRecord

  ## ASSOCIATIONS
  belongs_to :product
  has_one :shop, through: :product

  scope :with_shop, ->(shop_id) { joins(:product).where(products: {shop_id: shop_id}) }

end