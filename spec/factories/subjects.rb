require 'faker'

FactoryGirl.define do
  factory :subject do
    name Faker::Name.name
		age 1
		gender_id 1
		ethnicity_id 1
		armed false
		mentally_ill false
		veteran false
  end

end
