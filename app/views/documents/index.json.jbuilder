json.array!(@documents) do |document|
  json.extract! document, :id
  json.url document_url(document, format: :json)
end
