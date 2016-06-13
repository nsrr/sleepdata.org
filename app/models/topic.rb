# frozen_string_literal: true

# Allows users to start new discussion topics on the forum.
class Topic < ActiveRecord::Base
  attr_accessor :description

  # Concerns
  include Deletable

  # Callbacks
  after_commit :create_first_comment, on: :create

  # Named Scopes
  scope :not_banned, -> { joins(:user).merge(User.where(banned: false)) }
  def self.search(arg)
    # TODO: Implement full text search through PgSearch multisearchable
    where('1 = 1')
  end

  # Model Validation
  validates :title, :slug, :user_id, presence: true
  validates :title, length: { maximum: 40 }
  validates :description, presence: true, if: :new_record?
  validates :slug, uniqueness: { scope: :deleted }
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ }

  # Model Relationships
  belongs_to :user
  has_many :comments, -> { order :id }
  has_many :subscriptions
  has_many :subscribers, -> { current.where(emails_enabled: true).where(subscriptions: { subscribed: true }) }, through: :subscriptions, source: :user
  has_many :topic_tags
  has_many :tags, -> { where(deleted: false).order(:name) }, through: :topic_tags

  def to_param
    slug_was.to_s
  end

  def editable_by?(current_user)
    !locked? && !user.banned? && (user == current_user || current_user.system_admin?)
  end

  # Placeholder

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

  def create_first_comment
    comments.create description: description, user_id: user_id if description.present?
    get_or_create_subscription(user)
  end
end
