# frozen_string_literal: true

FactoryBot.define do
  factory :photo_candidate do
    association :case
    subject_name { 'Walter Scott' }
    source { 'wikimedia_commons' }
    title { 'Walter Scott portrait' }
    sequence(:image_url) do |n|
      "https://upload.wikimedia.org/wikipedia/commons/a/ab/example-#{n}.jpg"
    end
    page_url { 'https://commons.wikimedia.org/wiki/File:Walter_Scott.jpg' }
    license { 'CC BY-SA 4.0' }
    license_url { 'https://creativecommons.org/licenses/by-sa/4.0/' }
    author { 'Family member' }
    score { 3 }
    status { 'pending' }
    likely_mugshot { false }
  end
end
