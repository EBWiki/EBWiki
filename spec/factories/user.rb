# This will guess the User class
FactoryGirl.define do
  factory :user do
  	name "johnny"
    sequence :email do |n|
      "person#{n}@example.com"
    end
    password "password"
    password_confirmation "password"
    factory :admin do
    	admin true
    end
  end

  factory :user_with_article do
    name "johnny"
    email "user@example.com"
    password "password"
    password_confirmation "password"
    after :create do |article|
      user.articles << FactoryGirl.create(:article)
    end
  end
end