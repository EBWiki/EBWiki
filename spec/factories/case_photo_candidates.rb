# frozen_string_literal: true

FactoryBot.define do
  factory :case_photo_candidate do
    association :case
    sequence(:image_url) { |n| "https://example.com/photos/#{n}.jpg" }
    source_page_url { 'https://example.com/article' }
    source_name { 'openverse' }
    license_label { 'CC BY 4.0' }
    license_url { 'https://creativecommons.org/licenses/by/4.0/' }
    title { 'Jordan Rivera community memorial' }
    description { 'Portrait from a news story in Albany' }
    status { :pending }
  end
end
