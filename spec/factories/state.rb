# This will guess the Article class
FactoryGirl.define do
  sequence(:id)
  factory :state do |f|
    f.id
    f.name "New York"
    f.ansi_code "NY"
  end
  factory :state_ohio, :class => State do |f|
    f.id
    f.name "Ohio"
    f.ansi_code "OH"
    f.iso 'US-OH'
  end
end