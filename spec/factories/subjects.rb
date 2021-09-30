# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :subject do
    name { Faker::Name.name }
    age { 1 }
    gender
    ethnicity
    unarmed { false }
    mentally_ill { false }
    veteran { false }
  end
end
