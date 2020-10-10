# frozen_string_literal: true

# The subject (AKA victim) of the case
class Subject < ApplicationRecord
  belongs_to :case
  belongs_to :gender
  belongs_to :ethnicity
  validates :name, presence: { message: 'Name of the victim can\'t be blank.' }

  STRIPPED_ATTRIBUTES = %w[name].freeze
  auto_strip_attributes(*STRIPPED_ATTRIBUTES)
end
