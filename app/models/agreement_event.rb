class AgreementEvent < ActiveRecord::Base

  # Concerns
  include Deletable

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

end
