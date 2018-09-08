# frozen_string_literal: true

# Model representing USA state
class State < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged
  has_many :cases
  has_many :agencies
  searchkick
end
