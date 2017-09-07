# frozen_string_literal: true

# Represents a vote for or against a DAUA submission.
class Review < ApplicationRecord
  # Validations
  validates :agreement_id, :user_id, presence: true

  # Relationships
  belongs_to :agreement
  belongs_to :user
end
