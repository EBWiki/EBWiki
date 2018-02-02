# frozen_string_literal: true

# Initializes CE Model

class CalendarEvent < ActiveRecord::Base
  validates :title, presence: true

  attr_accessor :date_range

  belongs_to :user

  def all_day_event?
    start == start.midnight && self.end == self.end.midnight ? true : false
  end
end
