# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    content 'MyText'
    comentable_id 1
    commentable_type 'MyString'
  end
end
