# This will guess the Article class
FactoryGirl.define do

  factory :article do |f|
    f.sequence(:title) {|n| "#{n}Title"}
    f.overview "A new article"
    f.city "Albany"
    f.date Date.today
    f.state_id 33
    transient do
      subjects_count 5
    end


    after(:create) do |article, evaluator|
      create_list(:subject, evaluator.subjects_count, article: article)
    end
  end

  factory :invalid_article, class: Article do |f|
    f.title ""
    f.overview ""
    f.city ""
    f.date ""
    # association :state, name: nil
  end

end