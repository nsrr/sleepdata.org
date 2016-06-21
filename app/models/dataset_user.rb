# frozen_string_literal: true

# Allows users to be set as editors, viewers, and reviewers of a dataset.
class DatasetUser < ActiveRecord::Base
  ROLES = [['Editor', 'editor'], ['Viewer', 'viewer'], ['Reviewer', 'reviewer']]

  # Model Validation
  validates :user_id, :role, presence: true

  # Model Relationships
  belongs_to :dataset
  belongs_to :user
end
