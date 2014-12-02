class AgreementEvent < ActiveRecord::Base

  # Model Validation
  validates_presence_of :agreement_id, :user_id, :event_type, :event_at
  validates_presence_of :comment, if: :is_comment?

  # Model Relationships
  belongs_to :agreement
  belongs_to :user

  # Agreement Event Methods


  protected

  def is_comment?
    self.event_type == 'commented'
  end

end
