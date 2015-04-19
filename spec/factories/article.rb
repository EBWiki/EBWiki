# This will guess the Article class
FactoryGirl.define do
  factory :article do |f|
    f.title "Title"
    f.content "A new article"
    f.state_id 33
  end
end