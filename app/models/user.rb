# frozen_string_literal: true

# Defines the user model, relationships, and permissions.
class User < ApplicationRecord
  # Constants
  # Constants
  ORDERS = {
    "email" => "users.email",
    "email desc" => "users.email desc",
    "posts" => "users.replies_count",
    "posts desc" => "users.replies_count desc",
    "activity desc" => "(CASE WHEN (users.current_sign_in_at IS NULL) THEN users.created_at ELSE users.current_sign_in_at END) desc",
    "activity" => "(CASE WHEN (users.current_sign_in_at IS NULL) THEN users.created_at ELSE users.current_sign_in_at END)",
    "banned desc" => "users.shadow_banned",
    "banned" => "users.shadow_banned desc nulls last",
    "logins desc" => "users.sign_in_count desc",
    "logins" => "users.sign_in_count"
  }
  DEFAULT_ORDER = "(CASE WHEN (users.current_sign_in_at IS NULL) THEN users.created_at ELSE users.current_sign_in_at END) desc"

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
  acts_as_textcaptcha api_key: ENV["support_email"]

  def perform_textcaptcha?
    super && !Rails.env.test?
  end

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
  scope :admins, -> { current.where(admin: true) }
  scope :with_name, ->(arg) { where("users.full_name IN (?) or users.username IN (?)", arg, arg) }
  scope :no_spammer_or_shadow_banned, -> { where(spammer: [false, nil], shadow_banned: [false, nil]) }

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
  has_many :broadcasts, -> { current }
  has_many :data_request_reviews
  has_many :data_requests, -> { current }
  has_many :datasets, -> { current }
  has_many :dataset_file_audits
  has_many :dataset_reviews
  has_many :exports, -> { current }
  has_many :images
  has_many :notifications
  has_many :replies, -> { current.left_outer_joins(:broadcast, :topic).where(topics: { id: Topic.current}).or(current.left_outer_joins(:broadcast, :topic).where(broadcasts: { id: Broadcast.published })) }
  has_many :subscriptions
  has_many :tags, -> { current }
  has_many :topics, -> { current }
  has_many :topic_users

  # Methods
  def self.searchable_attributes
    %w(full_name email username)
  end

  def self.profile_review
    where.not(profile_bio: ["", nil]).or(
      where.not(profile_location: ["", nil])
    ).or(
      where.not(profile_picture: ["", nil])
    ).current.where(profile_reviewed: false).order(:id)
  end

  def self.spam_review
    current.where(shadow_banned: true, spammer: [nil, true])
  end

  def invites
    OrganizationUser.where(invite_email: email)
  end

  def profile_present?
    profile_bio.present? || profile_location.present?
  end

  def organizations
    Organization.current
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

  def all_comments
    if admin?
      Comment.current
    else
      comments
    end
  end

  def editable_broadcasts
    if admin?
      Broadcast.current
    else
      broadcasts
    end
  end

  def editable_topics
    if admin?
      Topic.current
    else
      topics.not_auto_locked
    end
  end

  def editable_replies
    if admin?
      Reply.current
    else
      replies
    end
  end

  def deletable_replies
    if admin?
      Reply
    else
      replies
    end
  end

  def all_data_requests
    if admin?
      DataRequest.current
    else
      data_requests
    end
  end

  def all_agreement_events
    if admin?
      AgreementEvent.all
    else
      agreement_events
    end
  end

  def review_editors_data_requests
    DataRequest.current.joins(:requests).merge(
      Request.where(dataset: all_review_editors_datasets)
    ).distinct
  end

  def review_viewers_data_requests
    DataRequest.current.joins(:requests).merge(
      Request.where(dataset: all_review_viewers_datasets)
    ).distinct
  end

  def principal_reviewable_data_requests
    DataRequest.current.joins(final_legal_document: :organization).merge(
      Organization.current.with_principal_reviewer(self)
    )
  end

  def digest_data_requests
    review_editors_data_requests.joins(:agreement_events).merge(AgreementEvent.digest)
  end

  def digest_data_requests_submitted
    digest_data_requests.merge(AgreementEvent.digest_submitted)
  end

  def digest_data_requests_resubmit
    digest_data_requests.merge(AgreementEvent.digest_resubmit)
  end

  def digest_data_requests_approved
    digest_data_requests.merge(AgreementEvent.digest_approved)
  end

  def editable_organizations
    Organization.current.with_editor(self)
  end

  def viewable_organizations
    Organization.current.with_viewer(self)
  end

  def organization_viewer?
    viewable_organizations.count.positive?
  end

  def organization_editor?
    editable_organizations.count.positive?
  end

  def all_datasets
    Dataset.current.with_editor(id)
  end

  def all_review_editors_datasets
    Dataset.current.with_review_editors(self)
  end

  def all_review_viewers_datasets
    Dataset.current.with_review_viewers(self)
  end

  def all_viewable_datasets
    Dataset.current.with_viewer_or_editor_or_approved(id)
  end

  def topics_created_in_last_day
    topics.where("created_at >= ?", Time.zone.today - 1.day)
  end

  def digest_reviews
    data_request_reviews
      .where("approved IS NULL or vote_cleared = ?", true)
      .joins(:data_request).merge(DataRequest.current.where(status: "submitted"))
      .order("agreements.last_submitted_at desc")
  end

  def initials
    full_name.split(" ").collect(&:first).join("").presence || username
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
    return if Rails.env.test?

    RegistrationMailer.welcome(self, data_request_id: data_request_id).deliver_now
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

  def set_as_spammer_and_destroy!
    topics.destroy_all
    Notification.where(reply: replies).destroy_all
    update(spammer: true)
    destroy
  end
end
