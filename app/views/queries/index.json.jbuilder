json.array!(@queries) do |query|
  json.extract! query, :id, :name, :content
  json.url query_url(query, format: :json)
end
