# frozen_string_literal: true

# Represents a user vote on a blog comment.
class BroadcastCommentUser < ActiveRecord::Base
  # Model Validation
  validates :broadcast_id, :broadcast_comment_id, :user_id, :vote, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :broadcast
  belongs_to :broadcast_comment

  # Model Methods
  def up_vote!
    update vote: 1
  end

  def down_vote!
    update vote: -1
  end

  def remove_vote!
    update vote: 0
  end
end
