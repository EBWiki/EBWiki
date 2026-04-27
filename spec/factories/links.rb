# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :link do
    url { Faker::Internet.url }
    association :linkable, factory: :case
  end
end
