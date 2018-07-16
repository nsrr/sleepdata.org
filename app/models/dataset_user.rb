# frozen_string_literal: true

# Allows users to be set as editors, viewers, and reviewers of a dataset.
class DatasetUser < ApplicationRecord
  ROLES = [["Editor", "editor"], ["Viewer", "viewer"], ["Reviewer", "reviewer"]]

  # Validations
  validates :role, presence: true

  # Relationships
  belongs_to :dataset
  belongs_to :user
end
