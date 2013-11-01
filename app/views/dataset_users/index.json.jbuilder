json.array!(@dataset_users) do |dataset_user|
  json.extract! dataset_user, :dataset_id, :user_id, :editor, :approved
  json.url dataset_user_url(dataset_user, format: :json)
end
