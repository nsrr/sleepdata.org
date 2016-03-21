# frozen_string_literal: true

class DatasetVersion < ApplicationRecord
  # Model Validation
  validates :dataset_id, :version, presence: true
  validates :version, uniqueness: { scope: :dataset_id, case_sensitive: false }

  # Model Relationships
  belongs_to :dataset
end
