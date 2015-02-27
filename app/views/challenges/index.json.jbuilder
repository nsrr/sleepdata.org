json.array!(@challenges) do |challenge|
  json.extract! challenge, :id, :name, :slug, :description, :user_id, :public, :deleted
  json.url challenge_url(challenge, format: :json)
end
