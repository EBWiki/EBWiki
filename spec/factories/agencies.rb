FactoryGirl.define do
  factory :agency do
    name "MyString"
    street_address "MyString"
    city "MyString"
    state_id 1
    zipcode "MyString"
    description "MyText"
    telephone "MyString"
    email "MyString"
    website "MyString"
    lead_officer "MyString"
  end

  factory :invalid_agency, class: Agency do |f|
    f.name ""
    f.street_address ""
    f.city ""
    f.telephone ""
    # association :state, name: nil
  end
end