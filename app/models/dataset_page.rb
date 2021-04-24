# frozen_string_literal: true

class DatasetPage < ApplicationRecord
  # Concerns
  include PgSearch::Model
  multisearchable against: [:contents, :page_path, :search_terms]
  include Squishable
  squish :contents, :search_terms

  # Validations
  validates :page_path, presence: true, uniqueness: { scope: :dataset_id }

  # Relationships
  belongs_to :dataset

  # Methods
  def name
    page_path.split("/").last
  end
end
