# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :subject do
    name { Faker::Name.name }
    age { 1 }
    association :case
    unarmed { false }
    mentally_ill { false }
    veteran { false }

    trait :with_gender do
      gender
    end

    trait :with_ethnicity do
      ethnicity
    end
  end
end
