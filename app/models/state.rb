class State < ApplicationRecord

  ## ASSOCIATIONS
  belongs_to :country

  ## VALIDATIONS
  validates :name, :code, presence: true
  validates :name, uniqueness: { scope: [:code, :country] }

  ## SCOPES
  scope :lookup, -> (string) { where('lower(name) = ?', string.downcase).or(where(code: string)) }

end
