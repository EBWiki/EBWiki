# This will guess the Article class
FactoryGirl.define do
  factory :state do |f|
    f.name "New York"
    f.id 33
    f.ansi_code "NY"
  end
end