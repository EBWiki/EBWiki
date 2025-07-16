# frozen_string_literal: true

# This will guess the User class
FactoryBot.define do
  factory :user do
    name { Faker::Name.name.gsub(/'/,'') }
    sequence :email do |n|
      "person#{n}@example.com"
    end
    password { 'password' }
    password_confirmation { 'password' }
    factory :admin do
      admin { true }
    end
    confirmed_at { Date.current }
  end
end
