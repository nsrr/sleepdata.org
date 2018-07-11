# frozen_string_literal: true

# Allows users to rate and review a user-submitted tool.
class ToolReview < ApplicationRecord
  # Validations
  validates :rating, presence: true
  validates :tool_id, uniqueness: { scope: :user_id }
  validates :rating, inclusion: { in: 1..5, message: "must be between 1 and 5 stars" }

  # Relationships
  belongs_to :tool, touch: true
  belongs_to :user
  has_many :notifications

  # Methods

  def create_notification!
    notification = \
      tool.user.notifications
          .where(tool_id: tool_id, tool_review_id: id)
          .first_or_create
    notification.mark_as_unread!
  end

  def destroy
    notifications.destroy_all
    super
  end
end
