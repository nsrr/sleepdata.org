# frozen_string_literal: true

# Allows users to discuss topics.
class Comment < ActiveRecord::Base
  COMMENTS_PER_PAGE = 20

  # Concerns
  include Deletable, Forkable

  # Callbacks
  after_create :touch_topic

  # Model Validation
  validates :topic_id, :description, :user_id, presence: true

  # Named Scopes
  scope :with_unlocked_topic, -> { joins(:topic).merge(Topic.where(locked: false)) }
  scope :digest_visible, lambda {
    current
      .joins(:topic).merge(Topic.current)
      .joins(:user).merge(User.current.where(banned: false))
  }

  # Model Relationships
  belongs_to :topic
  belongs_to :user

  def editable_by?(current_user)
    !topic.locked? && !user.banned? && (user == current_user || current_user.system_admin?)
  end

  def deletable_by?(current_user)
    user == current_user || current_user.system_admin?
  end

  def banned_or_deleted?
    user.banned? || deleted?
  end

  def number
    topic.comments.order(:id).pluck(:id).index(id) + 1
  rescue
    0
  end

  def send_reply_emails_in_background!
    fork_process(:send_reply_emails!)
  end

  # Reply Emails sends emails if the following conditions are met:
  # 1) The topic subscriber has email notifications enabled
  # AND
  # 2) The topic subscriber is not the post creator
  def send_reply_emails!
    return unless EMAILS_ENABLED
    topic.subscribers.where.not(id: user_id).each do |u|
      UserMailer.post_replied(self, u).deliver_later
    end
  end

  private

  def touch_topic
    topic.update last_comment_at: Time.zone.now
  end
end
