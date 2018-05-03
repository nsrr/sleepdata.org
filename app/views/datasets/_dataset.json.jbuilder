# frozen_string_literal: true

json.extract! dataset, :name, :description, :slug, :released, :created_at, :updated_at
json.creator dataset.user.username
