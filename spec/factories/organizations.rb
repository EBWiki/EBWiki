# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    name { Faker::Name.name }
    description { 'This is just for testing' }
    website { 'www.test.com' }
    telephone { '123456789' }
    avatar { 'MyString' }
  end
end
