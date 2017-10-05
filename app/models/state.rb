# frozen_string_literal: true

class State < ActiveRecord::Base
  has_many :articles
  has_many :agencies
  searchkick

  scope :from_agency, ->(agency) { where(id: agency.state_id) }
end
