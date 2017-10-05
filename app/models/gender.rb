# frozen_string_literal: true

class Gender < ActiveRecord::Base
  has_many :subjects
end
