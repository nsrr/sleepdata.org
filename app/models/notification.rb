# frozen_string_literal: true

# Tracks if a user has seen replies to blog posts and forum topics.
class Notification < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :broadcast, optional: true
  belongs_to :topic, optional: true
  belongs_to :reply, optional: true
  belongs_to :community_tool, optional: true
  belongs_to :community_tool_review, optional: true
  belongs_to :dataset, optional: true
  belongs_to :dataset_review, optional: true
  belongs_to :hosting_request, optional: true
  belongs_to :organization, optional: true
  belongs_to :export, optional: true

  # Methods

  def mark_as_unread!
    update created_at: Time.zone.now, read: false
  end
end
