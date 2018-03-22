# frozen_string_literal: true

# Encapsulates the many genders that are affected by this
class Gender < ActiveRecord::Base
  has_many :subjects
end
