# This will guess the Article class
FactoryGirl.define do

  factory :article do |f|
    f.sequence(:title) {|n| "#{n}Title"}
    f.overview "A new article"
    f.city "Albany"
    f.state_id 33
    f.date Date.today
    # association :state, name: "New York"
  end

  factory :invalid_article, class: Article do |f|
    f.title ""
    f.overview ""
    f.city ""
    f.state_id 0
    f.date ""
    # association :state, name: nil
  end

end