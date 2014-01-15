json.array!(@agreements) do |agreement|
  json.extract! agreement, :id, :user_id, :dua, :status, :history, :approval_date, :expiration_date
  json.url agreement_url(agreement, format: :json)
end
