# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    content { 'MyText' }
    user

    for_case # default to the :for_comment trait if none is specified

    trait :for_case do
      association :commentable, factory: :case
    end
  end
end
