class Agreement < ActiveRecord::Base

  serialize :history, Array

  mount_uploader :dua, PDFUploader

  STATUS = ["submitted", "approved", "resubmit"].collect{|i| [i,i]}

  # Concerns
  include Deletable

  # Callbacks
  after_create :dua_submitted

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

  private

  def dua_submitted
    User.system_admins.each do |system_admin|
      UserMailer.dua_submitted(system_admin, self).deliver if Rails.env.production?
    end
  end

end
