# frozen_string_literal: true

# Ahoy event model
class EbwikiEvent < ApplicationRecord
  include Ahoy::QueryMethods
  self.table_name = 'ahoy_events'

  belongs_to :visit
  belongs_to :user

  serialize :properties, JSON
end
