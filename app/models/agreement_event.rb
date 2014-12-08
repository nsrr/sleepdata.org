class AgreementEvent < ActiveRecord::Base

  # Concerns
  include Deletable

  # Callbacks
  after_create :email_mentioned_users

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
