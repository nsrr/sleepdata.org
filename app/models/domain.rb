# frozen_string_literal: true

# Represents the valid values and options for a variable
class Domain < ApplicationRecord
  serialize :options, Array

  # Model Validation
  validates :name, :dataset_id, :dataset_version_id, presence: true
  validates :name, format: { with: /\A[a-z]\w*\Z/i }
  validates :name, length: { maximum: 30 }
  validates :name, uniqueness: { scope: [:dataset_id, :dataset_version_id], case_sensitive: false }

  # Model Relationships
  belongs_to :dataset
  belongs_to :dataset_version
  has_many :variables

  # Domain Methods
  def values
    options.collect { |option| option[:value] }
  end
end
