# frozen_string_literal: true

# Details an entry in the agreement history.
class AgreementEvent < ActiveRecord::Base
  AGREEMENT_EVENTS_PER_PAGE = 20
  EVENT_TYPE = [['user_submitted', 'user_submitted'],
                ['reviewer_approved', 'reviewer_approved'],
                ['reviewer_rejected', 'reviewer_rejected'],
                ['commented', 'commented'],
                ['reviewer_changed_from_rejected_to_approved', 'reviewer_changed_from_rejected_to_approved'],
                ['reviewer_changed_from_approved_to_rejected', 'reviewer_changed_from_approved_to_rejected'],
                ['user_resubmitted', 'user_resubmitted'],
                ['principal_reviewer_required_resubmission', 'principal_reviewer_required_resubmission'],
                ['principal_reviewer_approved', 'principal_reviewer_approved'],
                ['tags_updated', 'tags_updated']]

  # TODO: Remove the following in 0.23.0
  serialize :added_tag_ids, Array
  serialize :removed_tag_ids, Array
  # TODO: End

  # Concerns
  include Deletable, Forkable

  # Callbacks
  after_commit :email_mentioned_users_in_background, on: :create

  # Named Scopes
  scope :with_current_agreement, -> { joins(:agreement).merge(Agreement.current) }
  scope :regular_members, -> { joins(:agreement).merge(Agreement.regular_members) }

  # Model Validation
  validates :agreement_id, :user_id, :event_type, :event_at, presence: true
  validates :comment, presence: true, if: :commented?

  # Model Relationships
  belongs_to :agreement
  belongs_to :user
  has_many :agreement_event_tags
  # TODO: Rename the following relationships in 0.23.0 to added_tags and removed_tags respectively
  has_many :rename_added_tags, -> { where 'agreement_event_tags.added = ?', true }, through: :agreement_event_tags, source: :tag
  has_many :rename_removed_tags, -> { where 'agreement_event_tags.added = ?', false }, through: :agreement_event_tags, source: :tag

  # Agreement Event Methods

  def banned_or_deleted?
    user.banned? || deleted?
  end

  def number
    agreement.agreement_events.order(:event_at).pluck(:id).index(id) + 1
  rescue
    0
  end

  def editable_by?(current_user)
    user == current_user || current_user.system_admin?
  end

  def deletable_by?(current_user)
    user == current_user || current_user.system_admin?
  end

  # TODO: Remove the following methods in 0.23.0
  def added_tags
    rename_added_tags
  end

  def removed_tags
    rename_removed_tags
  end
  # TODO: End

  def commented?
    event_type == 'commented'
  end

  def email_mentioned_users_in_background
    fork_process(:email_mentioned_users)
  end

  protected

  def email_mentioned_users
    return unless EMAILS_ENABLED
    users = User.current.reject { |u| u.username.blank? }.uniq.sort
    users.each do |user|
      UserMailer.mentioned_in_agreement_comment(self, user).deliver_later if event_type == 'commented' && comment.to_s.match(/@#{user.username}\b/i)
    end
  end
end
