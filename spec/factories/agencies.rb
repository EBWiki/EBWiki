# frozen_string_literal: true

FactoryBot.define do
  factory :agency do |f|
    f.sequence(:name) { |n| "#{n}_Agency" }
    f.state_id { 1 }
  end

  factory :invalid_agency, class: Agency do |f|
    f.name { '' }
    f.street_address { '' }
    f.city { '' }
    f.telephone { '' }
    # association :state, name: nil
  end
end
