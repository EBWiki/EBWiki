# frozen_string_literal: true

# The subject (AKA victim) of the case
class Subject < ActiveRecord::Base
  belongs_to :case
  belongs_to :gender
  belongs_to :ethnicity
  validates :name, presence: { message: 'Name of the victim can\'t be blank.' }
end
