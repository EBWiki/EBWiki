json.array!(@agencies) do |agency|
  json.extract! agency, :id, :name, :street_address, :city, :state_id, :zipcode, :description, :telephone, :email, :website, :lead_officer
  json.url agency_url(agency, format: :json)
end
