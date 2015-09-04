json.array!(@sourceables) do |local_file|
  json.extract! local_file, :id, :media, :media_fingerprint
  json.url local_file_url(local_file, format: :json)
end
