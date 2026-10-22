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
    summary { 'Added case' }
    blurb { 'Blurb about case' }
    video_url { 'https://example.com' }

    trait :memorial_photo_shown do
      photo_url { 'https://example.com/memorial-photo.jpg' }
      photo_source_url { 'https://example.org/photo-source' }
      photo_credit { 'Example Archive' }
      photo_status { 'shown' }
    end

    trait :memorial_photo_removed do
      photo_url { 'https://example.com/removed-photo.jpg' }
      photo_source_url { 'https://example.org/removed-source' }
      photo_credit { 'Example Archive' }
      photo_status { 'removed' }
    end
  end
end
