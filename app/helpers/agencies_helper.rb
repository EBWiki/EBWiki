# frozen_string_literal: true

module AgenciesHelper
  def show_non_blank_fields(label, value)
    "#{label}: #{value}" unless value.blank?
  end
end
