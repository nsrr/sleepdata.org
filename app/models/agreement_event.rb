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
  scope :with_current_agreement, -> { where( 'agreement_events.agreement_id in (select agreements.id from agreements where agreements.deleted = ?)', false ).references(:agreements) }

  # Model Validation
  validates_presence_of :agreement_id, :user_id, :event_type, :event_at
  validates_presence_of :comment, if: :is_comment?

  # Model Relationships
  belongs_to :agreement
  belongs_to :user

  # Agreement Event Methods

  def number
    self.agreement.agreement_events.order(:event_at).pluck(:id).index(self.id) + 1 rescue 0
  end

  def editable_by?(current_user)
    self.user == current_user or current_user.system_admin?
  end

  def deletable_by?(current_user)
    self.user == current_user or current_user.system_admin?
  end

  def added_tags
    @added_tags ||= begin
      Tag.review_tags.where(id: self.added_tag_ids)
    end
  end

  def removed_tags
    @removed_tags ||= begin
      Tag.review_tags.where(id: self.removed_tag_ids)
    end
  end

  protected

  def is_comment?
    self.event_type == 'commented'
  end

  def email_mentioned_users
    users = User.current.where(email_me_when_mentioned: true).reject{|u| u.username.blank?}.uniq.sort
    users.each do |user|
      UserMailer.mentioned_in_agreement_comment(self, user).deliver_later if Rails.env.production? and self.event_type == 'commented' and self.comment.to_s.match(/@#{user.username}\b/i)
    end
  end

end
