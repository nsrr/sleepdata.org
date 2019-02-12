# frozen_string_literal: true

# Allows broadcasts to be grouped by category.
class Category < ApplicationRecord
  # Constants
  ORDERS = {
    "name desc" => "categories.name desc",
    "name" => "categories.name",
    "slug desc" => "categories.slug desc",
    "slug" => "categories.slug"
  }
  DEFAULT_ORDER = "categories.name"

  # Concerns
  include Deletable
  include Searchable
  include Sluggable

  # Validations
  validates :name, :slug, presence: true
  validates :slug, uniqueness: { scope: :deleted }
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ }

  # Relationships
  has_many :broadcasts, -> { current }

  # Methods
  def self.searchable_attributes
    %w(name)
  end
end
