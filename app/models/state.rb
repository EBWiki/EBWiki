# frozen_string_literal: true

# Model representing USA state
class State < ActiveRecord::Base
  has_many :cases
  has_many :agencies
  searchkick
end
