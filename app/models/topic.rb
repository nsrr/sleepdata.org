class Topic < ActiveRecord::Base
  attr_accessor :description

  # Concerns
  include Deletable

  # Callbacks
  after_create :create_first_comment

  # Named Scopes
  scope :search, lambda { |arg| where("name ~* ? or id in (select comments.topic_id from comments where comments.description ~* ? and comments.deleted = ?)", arg.to_s.split(/\s/).collect{|l| l.to_s.gsub(/[^\w\d%]/, '')}.collect{|l| "(\\m#{l})"}.join("|"), arg.to_s.split(/\s/).collect{|l| l.to_s.gsub(/[^\w\d%]/, '')}.collect{|l| "(\\m#{l})"}.join("|"), false) }
  scope :with_author, lambda { |arg| where("name ~* ?", arg.to_s.split(/\s/).collect{|l| l.to_s.gsub(/[^\w\d%]/, '')}.collect{|l| "(\\m#{l})"}.join("|")) }
  scope :not_banned, -> { where( "topics.user_id IN ( select users.id from users where users.banned = ?)", false ).references(:users) }

  # Model Validation
  validates_presence_of :name, :user_id
  validates_length_of :name, maximum: 40
  validates_presence_of :description, if: :new_record?

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
    not self.locked? and not self.user.banned? and (self.user == current_user or current_user.system_admin?)
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
