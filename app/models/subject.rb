# frozen_string_literal: true

# The subject (AKA victim) of the case
class Subject < ApplicationRecord
  belongs_to :case
  belongs_to :gender
  belongs_to :ethnicity

  FORMATTED_ATTRIBUTES = %w[name].freeze
  
  # Model validations
  before_validation :format_attributes

  validates :name, presence: { message: 'Name of the victim can\'t be blank.' }

  private

  def format_attributes
    FORMATTED_ATTRIBUTES.each do |attribute|
      next unless self.public_send(attribute)
      formatted_value = self.public_send(attribute).strip.gsub(/,\z/, '')
      self.public_send("#{attribute}=", formatted_value)
    end
  end
end
