# frozen_string_literal: true

# Case categories
class Category < ActiveRecord::Base
  has_many :cases
end
