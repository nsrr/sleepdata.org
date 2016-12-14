# frozen_string_literal: true

# Allows users to rate and review a community tool.
class CommunityToolReview < ApplicationRecord
  # Model Validation
  validates :user_id, :community_tool_id, :rating, :review, presence: true
  validates :community_tool_id, uniqueness: { scope: :user_id }
  validates :rating, inclusion: { in: 1..5, message: 'must be between 1 and 5 stars' }

  # Model Relationships
  belongs_to :community_tool, touch: true
  belongs_to :user

  # Model Methods
end
