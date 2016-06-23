# frozen_string_literal: true

# Tracks if a user has seen replies to blog posts and forum topics.
class Notification < ActiveRecord::Base
  # Model Validation
  validates :user_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :broadcast
  belongs_to :topic
  belongs_to :reply

  # Notification Methods

  def mark_as_unread!
    update created_at: Time.zone.now, read: false
  end
end
