# frozen_string_literal: true

# Defines the user model, relationships, and permissions.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  # Concerns
  include Deletable, TokenAuthenticatable, Forkable

  # Callbacks
  before_save :ensure_authentication_token

  # Scopes
  scope :aug_members, -> { current.where(aug_member: true) }
  scope :core_members, -> { current.where(core_member: true) }
  scope :system_admins, -> { current.where(system_admin: true) }
  scope :with_name, -> (arg) { where("(users.first_name || ' ' || users.last_name) IN (?) or users.username IN (?)", arg, arg) }

  def self.search(arg)
    term = arg.to_s.downcase.gsub(/^| |$/, '%')
    conditions = [
      'LOWER(first_name) LIKE ?',
      'LOWER(last_name) LIKE ?',
      'LOWER(email) LIKE ?',
      '((LOWER(first_name) || LOWER(last_name)) LIKE ?)',
      '((LOWER(last_name) || LOWER(first_name)) LIKE ?)'
    ]
    terms = [term] * conditions.count
    where conditions.join(' or '), *terms
  end

  def self.aug_or_core_members
    current.where('aug_member = ? or core_member = ?', true, true)
  end

  def self.regular_members
    current.where(aug_member: false, core_member: false)
  end

  # Validations
  validates :first_name, :last_name, presence: true
  validates :username, uniqueness: { case_sensitive: false }, format: { with: /\A[a-z]\w*\Z/i }, allow_blank: true

  # Relationships
  has_many :agreements, -> { current }
  has_many :agreement_events
  has_many :answers
  has_many :broadcasts, -> { current }
  has_many :challenges, -> { current }
  has_many :community_tools, -> { current }
  has_many :community_tool_reviews
  has_many :data_requests, -> { current }
  has_many :datasets, -> { current }
  has_many :dataset_file_audits
  has_many :dataset_reviews
  has_many :hosting_requests, -> { current }
  has_many :images
  has_many :notifications
  has_many :replies, -> { current }
  has_many :reviews
  has_many :subscriptions
  has_many :tags, -> { current }
  has_many :topics, -> { current }
  has_many :topic_users

  # Methods

  def shadow_banned?
    false
  end

  def reviewed_tool?(tool)
    tool.community_tool_reviews.find_by(user_id: id).present?
  end

  def reviewed_dataset?(dataset)
    dataset.dataset_reviews.find_by(user_id: id).present?
  end

  def read_parent!(parent, current_reply_read_id)
    # TODO: Allow blog posts to be read as well...
    return unless parent.is_a?(Topic)
    topic_user = topic_users.where(topic_id: parent.id).first_or_create
    topic_user.update current_reply_read_id: [topic_user.current_reply_read_id.to_i, current_reply_read_id].max,
                      last_reply_read_id: topic_user.current_reply_read_id
  end

  def admin?
    system_admin?
  end

  def all_topics
    if system_admin?
      Topic.current
    else
      topics
    end
  end

  def all_comments
    if system_admin?
      Comment.current
    else
      comments
    end
  end

  def editable_broadcasts
    if system_admin?
      Broadcast.current
    else
      broadcasts
    end
  end

  def editable_replies
    if system_admin?
      Reply.current
    else
      replies
    end
  end

  def all_agreements
    if system_admin?
      Agreement.current
    else
      agreements
    end
  end

  def all_agreement_events
    if system_admin?
      AgreementEvent.all
    else
      agreement_events
    end
  end

  def reviewable_agreements
    Agreement.current.where('agreements.id IN (select requests.agreement_id from requests where requests.dataset_id IN (?))', all_reviewable_datasets.select(:id))
  end

  def all_datasets
    Dataset.current.with_editor(id)
  end

  def all_reviewable_datasets
    Dataset.current.with_reviewer(id)
  end

  def all_viewable_datasets
    Dataset.current.with_viewer_or_editor(id)
  end

  def all_viewable_challenges
    if system_admin?
      Challenge.current
    else
      Challenge.current.where(public: true)
    end
  end

  def all_challenges
    if system_admin?
      Challenge.current
    else
      challenges
    end
  end

  def avatar_url(size = 80, default = 'mm')
    gravatar_id = Digest::MD5.hexdigest(email_was.to_s.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?&s=#{size}&r=pg&d=#{default}"
  end

  def can_post_links?
    # aug_member? || core_member?
    true
  end

  def topics_created_in_last_day
    topics.where('created_at >= ?', Date.today - 1.day)
  end

  def max_topics
    if aug_member? || core_member?
      10
    else
      2
    end
  end

  def digest_reviews
    reviews.where(approved: nil).joins(:agreement).merge(Agreement.current.where(status: 'submitted')).order('agreements.last_submitted_at desc')
  end

  def name
    "#{first_name} #{last_name}"
  end

  def name_was
    "#{first_name_was} #{last_name_was}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def reverse_name_and_email
    "#{last_name}, #{first_name} - #{email}"
  end

  def initials
    "#{first_name.first.upcase}#{last_name.first.upcase}"
  end

  def id_and_auth_token
    "#{id}-#{authentication_token}"
  end

  def forum_name
    username.blank? ? name : username
  end

  def unread_notifications?
    notifications.where(read: false).count > 0
  end

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super && !deleted?
  end

  def destroy
    super
    update_column :updated_at, Time.zone.now
  end

  def send_welcome_email_with_password_in_background(pw)
    fork_process(:send_welcome_email_with_password, pw)
  end

  def send_welcome_email_with_password(pw)
    RegistrationMailer.send_welcome_email_with_password(self, pw).deliver_now if EMAILS_ENABLED
  end
end
