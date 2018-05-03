# frozen_string_literal: true

# Defines the user model, relationships, and permissions.
class User < ApplicationRecord
  # Constants
  COMMERCIAL_TYPES = [
    ["Noncommercial", "noncommercial"],
    ["Commercial", "commercial"]
  ]
  DATA_USER_TYPES = [
    ["Individual", "individual"],
    ["Organization", "organization"]
  ]

  # Include default devise modules. Others available are:
  # :lockable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Concerns
  include Deletable
  include TokenAuthenticatable
  include Forkable
  include Searchable
  include UsernameGenerator

  include Squishable
  squish :full_name

  include Strippable
  strip :username

  # Uploaders
  mount_uploader :profile_picture, ResizableImageUploader

  # Callbacks
  before_save :ensure_authentication_token

  # Scopes
  scope :aug_members, -> { current.where(aug_member: true) }
  scope :core_members, -> { current.where(core_member: true) }
  scope :system_admins, -> { current.where(system_admin: true) }
  scope :with_name, ->(arg) { where("users.full_name IN (?) or users.username IN (?)", arg, arg) }

  def self.aug_or_core_members
    current.where("aug_member = ? or core_member = ?", true, true)
  end

  def self.regular_members
    current.where(aug_member: false, core_member: false)
  end

  # Validations
  validates :full_name, format: { with: /\A.+\s.+\Z/, message: "must include first and last name" }, allow_blank: true
  validates :username, presence: true
  validates :username, format: {
    with: /\A[a-zA-Z0-9]+\Z/i,
    message: "may only contain letters or digits"
  },
                       exclusion: { in: %w(new edit show create update destroy) },
                       allow_blank: true,
                       uniqueness: { case_sensitive: false }
  validates :data_user_type, inclusion: { in: User::DATA_USER_TYPES.collect(&:second) }
  validates :commercial_type, inclusion: { in: User::COMMERCIAL_TYPES.collect(&:second) }

  # Relationships
  has_many :agreements, -> { current }
  has_many :agreement_events
  has_many :answers
  has_many :broadcasts, -> { current }
  has_many :challenges, -> { current }
  has_many :community_tools, -> { current }
  has_many :community_tool_reviews
  has_many :data_request_reviews
  has_many :data_requests, -> { current }
  has_many :datasets, -> { current }
  has_many :dataset_file_audits
  has_many :dataset_reviews
  has_many :exports, -> { current }
  has_many :hosting_requests, -> { current }
  has_many :images
  has_many :notifications
  has_many :replies, -> { current }
  has_many :subscriptions
  has_many :tags, -> { current }
  has_many :topics, -> { current }
  has_many :topic_users

  # Methods
  def self.searchable_attributes
    %w(full_name username email)
  end

  def organizations
    Organization.current
  end

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

  # This should take the organization into account.
  def principal_reviewer?(organization: nil)
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

  def all_data_requests
    if system_admin?
      DataRequest.current
    else
      data_requests
    end
  end

  def all_agreement_events
    if system_admin?
      AgreementEvent.all
    else
      agreement_events
    end
  end

  # TODO: rewrite using inner join?
  def reviewable_data_requests
    DataRequest.current.where(
      "agreements.id IN (select requests.agreement_id from requests where requests.dataset_id IN (?))",
      all_reviewable_datasets.select(:id)
    )
  end

  def all_datasets
    Dataset.current.with_editor(id)
  end

  def all_reviewable_datasets
    Dataset.current.with_reviewer(id)
  end

  def all_viewable_datasets
    Dataset.current.with_viewer_or_editor_or_approved(id)
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

  def topics_created_in_last_day
    topics.where("created_at >= ?", Time.zone.today - 1.day)
  end

  def max_topics
    if aug_member? || core_member?
      10
    else
      2
    end
  end

  def digest_reviews
    data_request_reviews
      .where("approved IS NULL or vote_cleared = ?", true)
      .joins(:data_request).merge(DataRequest.current.where(status: "submitted"))
      .order("agreements.last_submitted_at desc")
  end

  def initials
    full_name.split(" ").collect(&:first).join("")
  end

  def id_and_auth_token
    "#{id}-#{authentication_token}"
  end

  def unread_notifications?
    notifications.where(read: false).count.positive?
  end

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super && !deleted?
  end

  def destroy
    super
    update_column :updated_at, Time.zone.now
  end

  def send_welcome_email_in_background!(data_request_id: nil)
    fork_process :send_welcome_email!, data_request_id: data_request_id
  end

  def send_welcome_email!(data_request_id: nil)
    RegistrationMailer.welcome(self, data_request_id: data_request_id).deliver_now if EMAILS_ENABLED
  end

  # Disposable emails are one-off email address website generators.
  def disposable_email?
    DISPOSABLE_EMAILS.include?(email.split("@")[1])
  end

  # Blacklisted emails are email domains flagged for containing a high number of
  # spammers to legitimate users.
  def blacklisted_email?
    BLACKLISTED_EMAILS.include?(email.split("@")[1])
  end

  def send_confirmation_instructions
    return if disposable_email?
    super
  end

  def send_on_create_confirmation_instructions
    return if disposable_email?
    send_welcome_email_in_background!
  end

  def profile_present?
    profile_bio.present? || profile_location.present?
  end
end
