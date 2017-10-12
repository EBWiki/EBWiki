# frozen_string_literal: true

class Ethnicity < ActiveRecord::Base
  has_many :subjects
end
