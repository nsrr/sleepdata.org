# frozen_string_literal: true

# Tracks if a user has seen replies to blog posts and forum topics.
class Notification < ApplicationRecord
  # Validations
  validates :user_id, presence: true

  # Relationships
  belongs_to :user
  belongs_to :broadcast
  belongs_to :topic
  belongs_to :reply
  belongs_to :community_tool
  belongs_to :community_tool_review
  belongs_to :dataset
  belongs_to :dataset_review
  belongs_to :hosting_request

  # Methods

  def mark_as_unread!
    update created_at: Time.zone.now, read: false
  end
end
