# frozen_string_literal: true

# This will guess the Article class
FactoryBot.define do
  sequence(:id)

  factory :state do |f|
    f.id
    f.name { 'New York' }
    f.ansi_code { 'NY' }
  end

  factory :state_ohio, class: State do |f|
    f.id
    f.name { 'Ohio' }
    f.ansi_code { 'OH' }
    f.iso { 'US-OH' }
  end

  factory :state_texas, class: State do |f|
    f.id
    f.name { 'Texas' }
    f.ansi_code { 'TX' }
    f.iso { 'US-TX' }
  end

  factory :state_dc, class: State do |f|
    f.id
    f.name { 'District of Columbia' }
    f.ansi_code { 'DC' }
    f.iso { 'US-DC' }
  end

  factory :state_louisiana, class: State do |f|
    f.id
    f.name { 'Louisiana' }
    f.ansi_code { 'LA' }
    f.iso { 'US-LA' }
  end

  factory :state_ny, class: State do |f|
    f.id
    f.name { 'New York' }
    f.ansi_code { 'NY' }
    f.iso { 'US-NY' }
  end
end
