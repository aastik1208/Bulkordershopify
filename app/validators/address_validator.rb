class AddressValidator < ActiveModel::Validator
  def validate(record)
    return unless record.country_code.present? &&  record.postal_code.present? && record.state.present?

    country = Country.find_by(code: record.country_code)

    unless country.present?
      record.errors.add :base, :invalid_country_code
      return
    end

    unless ValidatesZipcode.valid?(record.postal_code, country.code)
      record.errors.add :base, :invalid_postal_code, country_name: country.name
    end

    if country.states.present?
      state = country.states.lookup(record.state)
      unless state.present?
        record.errors.add :base, :invalid_address_state, country_name: country.name
      end
    end

  end
end
