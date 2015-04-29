# This will guess the Article class
FactoryGirl.define do

  factory :article do |f|
    f.sequence(:title) {|n| "#{n}Title"}
    f.content "A new article"
    f.state_id 33
    f.date Date.today
  end
end