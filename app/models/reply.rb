# frozen_string_literal: true

# Allows community members to reply to forum topics and blog posts. Replies can
# also be nested under other replies.
class Reply < ApplicationRecord
  # Constants
  THRESHOLD = -10
  REPLIES_PER_PAGE = 20

  # Concerns
  include Deletable
  include PgSearch
  multisearchable against: [:description],
                  unless: :deleted_or_parent_deleted?

  # Named Scopes
  scope :points, -> { select('replies.*, COALESCE(SUM(reply_users.vote), 0)  points').joins('LEFT JOIN reply_users ON reply_users.reply_id = replies.id').group('replies.id') }

  # Model Validation
  validates :description, :user_id, presence: true
  # validates :topic_id, :broadcast_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :broadcast
  belongs_to :topic
  belongs_to :reply
  has_many :reply_users

  # Model Methods
  def destroy
    super
    update_pg_search_document
  end

  def deleted_or_parent_deleted?
    deleted? || (topic && topic.deleted?) || (broadcast && broadcast.deleted?)
  end

  # TODO: Make this work for blog posts
  def unread?(current_user)
    return false unless current_user
    return false unless topic
    topic_user = topic.topic_users.find_by user: current_user
    topic_user.nil? || (topic_user && topic_user.last_reply_read_id.to_i < id)
  end

  def display_links?
    rank >= 0
  end

  def parent
    topic || broadcast
  end

  def number
    parent.replies.where(reply_id: nil).pluck(:id).index(id) + 1
  rescue
    0
  end

  def page
    if reply
      reply.page
    else
      ((number - 1) / REPLIES_PER_PAGE) + 1
    end
  end

  def anchor
    "comment-#{id}"
  end

  def parent_author?
    parent.user_id == user_id
  end

  def rank
    @rank ||= reply_users.sum(:vote)
  end

  def reverse_rank
    -rank
  end

  def order_newest
    -id
  end

  def order_oldest
    id
  end

  def order_best
    [reverse_rank, order_newest]
  end

  def below_threshold?
    deleted? || rank < THRESHOLD
  end

  def vote(current_user)
    reply_user = reply_users.find_by(user: current_user)
    return nil unless reply_user
    case reply_user.vote
    when 1
      true
    when -1
      false
    end
  end

  def parent_reply_id
    reply_id || 'root'
  end

  def computed_level
    return 0 if reply_id.nil?
    reply.computed_level + 1
  end

  def editable_by?(current_user)
    current_user.editable_replies.where(id: id).count == 1
  end

  def create_notifications!
    parent.subscribers.where.not(id: user_id).each do |u|
      notification = u.notifications.where(topic_id: topic_id, broadcast_id: broadcast_id, reply_id: id).first_or_create
      notification.mark_as_unread!
    end
  end
end
