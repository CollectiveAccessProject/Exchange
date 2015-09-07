json.array!(@youtube_links) do |youtube_link|
  json.extract! youtube_link, :id, :key, :original_link
  json.url youtube_link_url(youtube_link, format: :json)
end
