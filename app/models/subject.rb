# frozen_string_literal: true

# The subject (AKA victim) of the case
class Subject < ApplicationRecord
  belongs_to :case
  belongs_to :gender
  belongs_to :ethnicity

  # Model validations
  sanitize :name

  validates :name, presence: { message: 'Name of the victim can\'t be blank.' }
end
