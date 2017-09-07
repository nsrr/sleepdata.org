# frozen_string_literal: true

class DatasetVersion < ApplicationRecord
  # Validations
  validates :dataset_id, :version, presence: true
  validates :version, uniqueness: { scope: :dataset_id, case_sensitive: false }

  # Relationships
  belongs_to :dataset
end
