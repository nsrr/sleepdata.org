# frozen_string_literal: true

# Allows broadcasts to be grouped by category.
class Category < ApplicationRecord
  # Concerns
  include Deletable, Searchable, Sluggable

  # Model Validation
  validates :name, :slug, presence: true
  validates :slug, uniqueness: { scope: :deleted }
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ }

  # Model Relationships
  has_many :broadcasts, -> { current }

  # Model Methods
  def self.searchable_attributes
    %w(name)
  end
end
