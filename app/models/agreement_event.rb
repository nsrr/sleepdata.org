class AgreementEvent < ActiveRecord::Base
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

  serialize :added_tag_ids, Array
  serialize :removed_tag_ids, Array

  # Concerns
  include Deletable

  # Callbacks
  after_create :email_mentioned_users

  # Named Scopes
  scope :with_current_agreement, -> { joins(:agreement).merge(Agreement.current) }
  scope :regular_members, -> { joins(:agreement).merge(Agreement.regular_members) }

  # Model Validation
  validates :agreement_id, :user_id, :event_type, :event_at, presence: true
  validates :comment, presence: true, if: :is_comment?

  # Model Relationships
  belongs_to :agreement
  belongs_to :user

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

  def added_tags
    @added_tags ||= begin
      Tag.review_tags.where(id: added_tag_ids)
    end
  end

  def removed_tags
    @removed_tags ||= begin
      Tag.review_tags.where(id: removed_tag_ids)
    end
  end

  def is_comment?
    event_type == 'commented'
  end

  protected

  def email_mentioned_users
    users = User.current.reject { |u| u.username.blank? }.uniq.sort
    users.each do |user|
      UserMailer.mentioned_in_agreement_comment(self, user).deliver_later if EMAILS_ENABLED && event_type == 'commented' && comment.to_s.match(/@#{user.username}\b/i)
    end
  end
end
