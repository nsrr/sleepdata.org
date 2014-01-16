class Agreement < ActiveRecord::Base

  serialize :history, Array

  mount_uploader :dua, PDFUploader

  STATUS = ["submitted", "approved", "resubmit"].collect{|i| [i,i]}

  # Concerns
  include Deletable

  # Model Validation
  validates_presence_of :dua, :user_id

  # Model Relationships
  belongs_to :user

  # Agreement Methods

  def name
    self.user ? self.user.name + " Request" : "##{self.id}"
  end

  def approved?
    self.status == 'approved'
  end

  def resubmission_required?
    self.status == 'resubmit'
  end

  def add_event!(message, current_user, status)
    self.history << { message: message, user_id: current_user.id, event_at: Time.now, status: status }
    self.status = status
    self.save
  end

end
