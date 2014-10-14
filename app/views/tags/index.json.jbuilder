json.array!(@tags) do |tag|
  json.extract! tag, :id, :name, :color, :user_id, :deleted
  json.url tag_url(tag, format: :json)
end
