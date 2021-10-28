# frozen_string_literal: true

# == Schema Information
#
# Table name: calendar_events
#
#  id             :bigint           not null, primary key
#  city           :string
#  description    :text             not null
#  format         :string
#  schedule       :jsonb            not null
#  state          :string
#  street_address :string
#  title          :string           not null
#  zipcode        :string
#  owner_id       :bigint
#
# Indexes
#
#  index_calendar_events_on_owner_id  (owner_id)
#
class CalendarEvent < ApplicationRecord
  sanitize :title, :street_address, :city, :state, :zipcode, :description
  validates_presence_of :title, :schedule, :description
  has_many :links, dependent: :destroy
  serialize :schedule, Montrose::Schedule

  enum format: {
    in_person: 'in_person',
    virtual: 'virtual',
    hybrid: 'hybrid'
  }

  def location
    Location.new(
      state: state,
      street_location: street_address,
      city: city,
      zipcode: zipcode
    )
  end

  def location=(location)
    self.state = State.find_by_name(location.state).name
    self.street_address = location.street_location
    self.city = location.city
    self.zipcode = location.zipcode
  end
end
