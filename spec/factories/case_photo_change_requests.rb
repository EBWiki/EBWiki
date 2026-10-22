# frozen_string_literal: true

FactoryBot.define do
  factory :case_photo_change_request do
    association :case
    request_type { :remove }
    status { :pending }
    message { 'Please remove this photo.' }
    requester_contact { 'family@example.com' }
  end
end
