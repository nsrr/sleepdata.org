# frozen_string_literal: true

# Allows community members to reply to forum topics and blog posts. Replies can
# also be nested under other replies.
class Reply < ApplicationRecord
  # Constants
  ORDERS = {
    "best" => "points",
    "points" => "points",
    "points desc" => "points desc",
    "newest" => "replies.created_at desc",
    "oldest" => "replies.created_at"
  }
  DEFAULT_ORDER = "replies.created_at desc"

  THRESHOLD = -10
  REPLIES_PER_PAGE = 20

  # Concerns
  include Deletable
  include PgSearch::Model
  include UrlCountable
  multisearchable against: [:description],
                  unless: :deleted_or_parent_deleted?
  include Strippable
  strip :description

  # Scopes
  scope :points, -> { select("replies.*, COALESCE(SUM(reply_users.vote), 0) points").joins("LEFT JOIN reply_users ON reply_users.reply_id = replies.id").group("replies.id") }
  scope :shadow_banned, -> (arg) { joins(:user).merge(User.where(shadow_banned: [nil, false]).or(User.where(id: arg))) }

  # Validations
  validates :description, presence: true

  # Relationships
  belongs_to :user, counter_cache: true
  belongs_to :broadcast, optional: true, counter_cache: true
  belongs_to :topic, optional: true, counter_cache: true
  belongs_to :reply, foreign_key: :reply_id, optional: true
  has_many :reply_users

  # Methods
  def destroy
    super
    Notification.where(reply_id: id).destroy_all
    parent.class.reset_counters(parent.id, :countable_replies)
    User.reset_counters(user.id, :replies)
    update_pg_search_document
    return unless parent.replies.where(reply_id: id).count.zero?
    reply_users.delete_all
    delete
  end

  def deleted_or_parent_deleted?
    deleted? || topic&.deleted? || broadcast&.deleted? || user.spammer? || user.shadow_banned?
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
    (parent.replies.where(reply_id: nil).pluck(:id).index(id) || -1) + 1
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

  def display_for_user?(current_user)
    current_user == user || !below_threshold?
  end

  def below_threshold?
    deleted? || rank < THRESHOLD || user.shadow_banned?
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
    reply_id || "root"
  end

  def computed_level
    return 0 if reply_id.nil?
    reply.computed_level + 1
  end

  def editable_by?(current_user)
    current_user.editable_replies.where(id: id).count == 1
  end

  def create_notifications!
    parent.subscribers.where.not(id: user_id).find_each do |u|
      notification = u.notifications.where(topic_id: topic_id, broadcast_id: broadcast_id, reply_id: id).first_or_create
      notification.mark_as_unread!
    end
  end

  def compute_shadow_ban!
    user.update shadow_banned: true if user.shadow_banned.nil? && url_count > 1
  end

  def url_count
    if user.sign_in_count == 1
      count_urls(description) * 2 + email_count
    else
      count_urls(description) + email_count
    end
  end

  def email_count
    BANNED_EMAILS.each do |banned_email|
      return banned_email["score"] unless (/#{banned_email["email"]}$/ =~ user.email).nil?
    end
    0
  end
end
