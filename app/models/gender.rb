# frozen_string_literal: true

# Encapsulates the many genders that are affected by this
class Gender < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :subjects
  alias_attribute :name, :sex
end
