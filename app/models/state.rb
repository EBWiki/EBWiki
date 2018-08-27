# frozen_string_literal: true

# Model representing USA state
class State < ApplicationRecord
  has_many :cases
  has_many :agencies
  searchkick
end
