# frozen_string_literal: true

# Encapsulates the many genders that are affected by this
class Gender < ApplicationRecord
  has_many :subjects
  alias_attribute :name, :sex
end
