json.array!(@organizations) do |organization|
  json.extract! organization, :id, :name, :description, :website, :telephone, :avatar
  json.url organization_url(organization, format: :json)
end
