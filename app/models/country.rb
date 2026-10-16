class Country < ApplicationRecord

  ## ASSOCIATIONS
  has_many :states, dependent: :destroy
  accepts_nested_attributes_for :states

  ## VALIDATIONS
  validates :name, :code, presence: true
  validates :name, uniqueness: { scope: :code }

  ## SCOPES
  scope :lookup_name, -> (string) { where('lower(name) = ?', string.downcase) }
  scope :lookup_code, -> (string) { where(code: string.upcase) }

end
