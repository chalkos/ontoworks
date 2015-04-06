json.array!(@queries) do |query|
  json.extract! query, :id, :name, :content
end
