# frozen_string_literal: true

module Ahoy
  # Ahoy event used for tracking activity
  class Event < ApplicationRecord
    include Ahoy::Properties
    self.table_name = 'ahoy_events'

    belongs_to :visit
    belongs_to :user

    serialize :properties, JSON
  end
end
