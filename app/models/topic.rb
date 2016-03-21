# frozen_string_literal: true

# Topics group together discussions on the forum.
class Topic < ActiveRecord::Base
  attr_accessor :description

  # Concerns
  include Deletable

  # Callbacks
  after_create :create_first_comment

  # Named Scopes
  scope :not_banned, -> { joins(:user).merge(User.where(banned: false)) }
  def self.search(arg)
    where(
      'topics.name ~* ? or topics.id in (select comments.topic_id from comments where comments.description ~* ? and comments.deleted = ?)',
      arg.to_s.split(/\s/).collect { |l| l.to_s.gsub(/[^\w\d%]/, '') }.collect { |l| "(\\m#{l})" }.join('|'),
      arg.to_s.split(/\s/).collect { |l| l.to_s.gsub(/[^\w\d%]/, '') }.collect { |l| "(\\m#{l})" }.join('|'),
      false
    )
  end

  # Model Validation
  validates :name, :user_id, presence: true
  validates :name, length: { maximum: 40 }
  validates :description, presence: true, if: :new_record?

  # Model Relationships
  has_many :comments
  belongs_to :user
  has_many :subscriptions
  has_many :subscribers, -> { current.where(emails_enabled: true).where(subscriptions: { subscribed: true }) }, through: :subscriptions, source: :user
  has_many :topic_tags
  has_many :tags, -> { where(deleted: false).order(:name) }, through: :topic_tags

  def to_param
    "#{id}-#{name.parameterize}"
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
    comments.create(description: description, user_id: user_id)
    get_or_create_subscription(user)
  end
end
