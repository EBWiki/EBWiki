# This will guess the Article class
FactoryGirl.define do
  factory :follow do |f|
    f.follower_id 1
    f.followable_id 1
  end
end