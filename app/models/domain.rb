# frozen_string_literal: true

# Represents the valid values and options for a variable.
class Domain < ApplicationRecord
  # Validations
  validates :name, :dataset_id, :dataset_version_id, presence: true
  validates :name, format: { with: /\A[a-z]\w*\Z/i }
  validates :name, length: { maximum: 30 }
  validates :name, uniqueness: { scope: [:dataset_id, :dataset_version_id], case_sensitive: false }

  # Relationships
  belongs_to :dataset
  belongs_to :dataset_version
  has_many :variables
  has_many :domain_options, -> { order(:position) }, dependent: :destroy

  # Methods
end
