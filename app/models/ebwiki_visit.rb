# frozen_string_literal: true

# Visit capturing user activity for Ahoy:
# https://github.com/ankane/ahoy
class EbwikiVisit < ApplicationRecord
  self.table_name = 'visits'
  has_many :ahoy_events, class_name: 'EbwikiEvent'
  belongs_to :user

  scope :this_month, -> { where(started_at: 30.days.ago.beginning_of_day..Time.current) }
  scope :this_week, -> { where(started_at: 7.days.ago.beginning_of_day..Time.current) }
  scope :today, -> { where(started_at: 1.days.ago.beginning_of_day..Time.current) }
  scope :most_recent, ->(duration) { where(started_at: duration.beginning_of_day..Time.current) }
  scope :occurring_by, ->(date) { where('started_at < ?', date.end_of_day) }
end
