# frozen_string_literal: true

FactoryBot.define do
  factory :calendar_event do
    title { 'Test event' }
    street_address { 'Str. Test' }
    city { 'Worthington' }
    state { 'Ohio' }
    zipcode { '77030' }
    description { 'Test calendar event' }
    schedule { Montrose::Schedule.new }
  end
end
