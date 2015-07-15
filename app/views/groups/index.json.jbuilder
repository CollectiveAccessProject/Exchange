json.array!(@groups) do |group|
  json.extract! group, :id, :name, :slug, :description, :type
  json.url group_url(group, format: :json)
end
