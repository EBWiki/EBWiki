# frozen_string_literal: true

FactoryBot.define do
  factory :conversation do
    subject { 'Something you might be interested in' }
    association :originator, factory: :user
  end
end
