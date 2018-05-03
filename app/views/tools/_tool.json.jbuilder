# frozen_string_literal: true

json.extract! tool, :name, :slug, :url, :description, :rating, :published, :publish_date, :series, :created_at, :updated_at
json.creator tool.user.username
