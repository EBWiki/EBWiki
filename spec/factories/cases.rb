# frozen_string_literal: true

FactoryBot.define do
  factory :case do
    sequence :title do |n| 
      "#{n}Title" 
    end
    overview { 'A new case' }
    city { 'Albany' }
    date { Date.current }
    state
    subjects { [] }
    user
    summary { 'Added case' }
    blurb { 'Blurb about case' }
  end
end
