# frozen_string_literal: true

FactoryBot.define do
  factory :case_photo_candidate do
    association :case
    sequence(:image_url) do |n|
      "https://api.openverse.org/v1/thumbs/00000000-0000-4000-8000-#{format('%012d', n)}"
    end
    source_page_url { 'https://example.com/article' }
    source_name { 'openverse' }
    license_label { 'CC BY 4.0' }
    license_url { 'https://creativecommons.org/licenses/by/4.0/' }
    title { 'Jordan Rivera community memorial' }
    description { 'Portrait from a news story in Albany' }
    status { :pending }
  end
end
