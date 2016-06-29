json.array!(@agencies) do |agency|
  json.extract! agency, :id
  json.url agency_url(agency, format: :json)
end
