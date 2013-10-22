json.extract! dataset, :name, :description, :slug, :public, :created_at, :updated_at
json.creator dataset.user.name
