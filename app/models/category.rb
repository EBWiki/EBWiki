# frozen_string_literal: true

# Case categories
class Category < ApplicationRecord
  has_many :cases
end
