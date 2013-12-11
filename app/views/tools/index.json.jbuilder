json.array!(@tools) do |tool|
  json.extract! tool, :id, :name, :text, :slug, :logo, :user_id, :deleted
  json.url tool_url(tool, format: :json)
end
