# frozen_string_literal: true

# This will guess the Article class
FactoryBot.define do
  factory :case do |f|
    f.sequence(:title) { |n| "#{n}Title" }
    f.overview { 'A new case' }
    f.city { 'Albany' }
    f.date { Date.current }
    f.state # { FactoryBot.create(:state) }
    f.subjects { [create(:subject, case:f, gender: create(:gender), ethnicity: create(:ethnicity))] }
    f.links { [create(:link)] }
    f.latitude { 50.00000 }
    f.longitude { 113.000 }
    f.summary { 'A summary of changes' }
    f.blurb { 'Blurb about case' }
  end

  factory :invalid_case, class: Case do |f|
    f.title { '' }
    f.overview { '' }
    f.city { '' }
    f.date { '' }
    f.summary { '' }
    # association :state, name: nil
  end
end
