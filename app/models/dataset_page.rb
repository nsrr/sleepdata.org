# frozen_string_literal: true

class DatasetPage < ApplicationRecord
  # Concerns
  include PgSearch::Model
  multisearchable against: [:contents]
  include Squishable
  squish :contents

  # Validations
  validates :page_path, presence: true, uniqueness: { scope: :dataset_id }

  # Relationships
  belongs_to :dataset

  # Methods
  def name
    page_path.split("/").last
  end
end
