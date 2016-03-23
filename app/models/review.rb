# frozen_string_literal: true

# Represents a vote for or against a DAUA submission.
class Review < ApplicationRecord
  # Model Validation
  validates :agreement_id, :user_id, presence: true

  # Model Relationships
  belongs_to :agreement
  belongs_to :user
end
