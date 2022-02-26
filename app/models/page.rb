# frozen_string_literal: true

# About page questions and answers.
class Page < ApplicationRecord
  # Constants
  ORDERS = {
    "id desc" => "pages.id desc",
    "id" => "pages.id nulls last",
    "published desc" => "pages.published",
    "published" => "pages.published desc"
  }
  DEFAULT_ORDER = "pages.id nulls last"

  # Concerns
  include PgSearch::Model
  multisearchable against: [:slug, :title, :description], if: :published?
  include Deletable
  include Searchable
  include Sluggable

  # Scopes
  scope :published, -> { current.where(published: true) }

  # Validations
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ },
                   exclusion: { in: %w(new edit create update destroy) },
                   allow_nil: true

  # Relationships
  belongs_to :folder, optional: true

  # Methods
  def self.searchable_attributes
    %w(slug title description)
  end

  def destroy
    super
    update slug: nil
    update_pg_search_document
  end
end
