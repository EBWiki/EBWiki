# frozen_string_literal: true

FactoryBot.define do
  factory :event_status do
    name { Faker::Name.name }
  end
end
