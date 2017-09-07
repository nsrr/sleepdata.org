# frozen_string_literal: true

# Allows users to start new discussion topics on the forum.
class Topic < ApplicationRecord
  attr_accessor :description

  # Concerns
  include Deletable
  include Replyable
  include PgSearch
  include Sluggable
  multisearchable against: [:title],
                  unless: :deleted?

  # Callbacks
  after_create_commit :create_first_reply

  # Scopes
  scope :not_banned, -> { joins(:user).merge(User.where(banned: false)) }
  scope :reply_count, -> { select('topics.*, COUNT(replies.id) reply_count').joins(:replies).group('topics.id') }

  # Validations
  validates :title, :slug, :user_id, presence: true
  validates :title, length: { maximum: 40 }
  validates :description, presence: true, if: :new_record?
  validates :slug, uniqueness: { scope: :deleted } # TODO: Uniqueness can't be constrained to deleted topics
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ }

  # Relationships
  belongs_to :user
  has_many :topic_users
  has_many :subscriptions
  has_many :subscribers, -> { current.where(subscriptions: { subscribed: true }) }, through: :subscriptions, source: :user
  has_many :topic_tags
  has_many :tags, -> { current.order(:name) }, through: :topic_tags

  # Methods
  def destroy
    super
    update_pg_search_document
    replies.each(&:update_pg_search_document)
  end

  def started_reading?(current_user)
    topic_user = topic_users.find_by user: current_user
    topic_user ? true : false
  end

  def unread_replies(current_user)
    topic_user = topic_users.find_by user: current_user
    if topic_user
      root_replies.current.where('id > ?', topic_user.current_reply_read_id).count
    else
      0
    end
  end

  def next_unread_reply(current_user)
    topic_user = topic_users.find_by user: current_user
    root_replies.current.find_by('id > ?', topic_user.current_reply_read_id) if topic_user
  end

  def root_replies
    replies.where(reply_id: nil)
  end

  def editable_by?(current_user)
    !locked? && !user.banned? && (user == current_user || current_user.system_admin?)
  end

  def get_or_create_subscription(current_user)
    current_user.subscriptions.where(topic_id: id).first_or_create
  end

  def set_subscription!(notify, current_user)
    get_or_create_subscription(current_user).update subscribed: notify
  end

  def subscribed?(current_user)
    current_user.subscriptions.where(topic_id: id, subscribed: true).count > 0
  end

  private

  def create_first_reply
    replies.create description: description, user_id: user_id if description.present?
    get_or_create_subscription(user)
  end
end
