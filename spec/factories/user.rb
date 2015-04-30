# This will guess the User class
FactoryGirl.define do
  factory :user do
  	email "user@example.com"
    password "password"
    password_confirmation "password"
    factory :admin do
    	admin true
    end
  end
end