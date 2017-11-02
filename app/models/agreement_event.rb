# frozen_string_literal: true

# Details an entry in the agreement history.
class AgreementEvent < ApplicationRecord
  AGREEMENT_EVENTS_PER_PAGE = 20
  EVENT_TYPE = [['user_submitted', 'user_submitted'],
                ['reviewer_approved', 'reviewer_approved'],
                ['reviewer_rejected', 'reviewer_rejected'],
                ['commented', 'commented'],
                ['reviewer_changed_from_rejected_to_approved', 'reviewer_changed_from_rejected_to_approved'],
                ['reviewer_changed_from_approved_to_rejected', 'reviewer_changed_from_approved_to_rejected'],
                ['user_resubmitted', 'user_resubmitted'],
                ['principal_reviewer_required_resubmission', 'principal_reviewer_required_resubmission'],
                ["principal_reviewer_approved", "principal_reviewer_approved"],
                ["principal_reviewer_closed", "principal_reviewer_closed"], # TODO: Add partial for "principal reviewer closed" event
                ["principal_reviewer_expired", "principal_reviewer_expired"], # TODO: Add partial for "principal reviewer expired" event
                ['tags_updated', 'tags_updated']]

  # Concerns
  include Deletable, Forkable

  # Callbacks
  after_create_commit :email_mentioned_users_in_background

  # Scopes
  scope :with_current_agreement, -> { joins(:agreement).merge(Agreement.current) }
  scope :regular_members, -> { joins(:agreement).merge(Agreement.regular_members) }

  # Validations
  validates :agreement_id, :user_id, :event_type, :event_at, presence: true
  validates :comment, presence: true, if: :commented?

  # Relationships
  belongs_to :agreement
  belongs_to :user
  has_many :agreement_event_tags
  has_many :added_tags, -> { where 'agreement_event_tags.added = ?', true }, through: :agreement_event_tags, source: :tag
  has_many :removed_tags, -> { where 'agreement_event_tags.added = ?', false }, through: :agreement_event_tags, source: :tag

  # Methods

  def data_request
    DataRequest.find_by(id: agreement_id)
  end

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

  def commented?
    event_type == 'commented'
  end

  def email_mentioned_users_in_background
    fork_process(:email_mentioned_users)
  end

  protected

  def email_mentioned_users
    return unless EMAILS_ENABLED && commented?
    users = User.current.where.not(username: [nil, ''])
    users.each do |user|
      next if (/@#{user.username}\b/i =~ comment.to_s).nil?
      UserMailer.mentioned_in_agreement_comment(self, user).deliver_now
    end
  end
end
