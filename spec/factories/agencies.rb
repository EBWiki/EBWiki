FactoryGirl.define do
  factory :agency do |f|
    f.name "MyAgency"
    f.street_address "230 West 43rd St."
    f.city "New York City"
    f.state
    f.zipcode "10036"
    f.description "MyText"
    f.telephone "MyString"
    f.email "MyString"
    f.website "MyString"
    f.lead_officer "MyString"
  end

  factory :invalid_agency, class: Agency do |f|
    f.name ""
    f.street_address ""
    f.city ""
    f.telephone ""
    # association :state, name: nil
  end
end