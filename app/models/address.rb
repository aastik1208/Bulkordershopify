class Address < ApplicationRecord

  include ActiveModel::Validations

  ## CONSTANTS
  CATEGORIES = {
    shipping: 0,
    billing: 1
  }

  ##
  enum category: CATEGORIES

  ## ASSOCIATIONS
  belongs_to :order, optional: true

  ## VALIDATIONS
  validates :first_name, :last_name, :address_line_1, :city, :state, :postal_code, :country_code, presence: true
  validates_with AddressValidator

  def pretty_errors
    errors.full_messages.join(", ")
  end

end
