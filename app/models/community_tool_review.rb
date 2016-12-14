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
  has_many :notifications

  # Model Methods

  def create_notification!
    notification = community_tool.user.notifications
                                 .where(community_tool_id: community_tool_id, community_tool_review_id: id)
                                 .first_or_create
    notification.mark_as_unread!
  end

  def destroy
    notifications.destroy_all
    super
  end
end
