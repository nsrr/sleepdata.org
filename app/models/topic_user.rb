# frozen_string_literal: true

# Tracks how far has read through a forum topic.
class TopicUser < ApplicationRecord
  # Validations
  validates :topic_id, :user_id, presence: true
  validates :user_id, uniqueness: { scope: :topic_id }

  # Relationships
  belongs_to :topic
  belongs_to :user
end
