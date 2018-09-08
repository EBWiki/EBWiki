# frozen_string_literal: true

# This will guess the Article class
FactoryBot.define do
  sequence(:id)

  factory :state do |f|
    f.id
    f.name { Faker::Name.name }
    f.ansi_code { 'NY' }
  end

  factory :state_ohio, class: State do |f|
    f.id
    f.name { Faker::Name.name }
    f.ansi_code { 'OH' }
    f.iso { 'US-OH' }
  end

  factory :state_texas, class: State do |f|
    f.id
    f.name { Faker::Name.name }
    f.ansi_code { 'TX' }
    f.iso { 'US-TX' }
  end

  factory :state_dc, class: State do |f|
    f.id
    f.name { Faker::Name.name }
    f.ansi_code { 'DC' }
    f.iso { 'US-DC' }
  end

  factory :state_louisiana, class: State do |f|
    f.id
    f.name { Faker::Name.name }
    f.ansi_code { 'LA' }
    f.iso { 'US-LA' }
  end
end
