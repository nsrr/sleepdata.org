class Agreement < ActiveRecord::Base

  serialize :history, Array

  mount_uploader :dua, PDFUploader
  mount_uploader :executed_dua, PDFUploader

  STATUS = ["submitted", "approved", "resubmit", "expired"].collect{|i| [i,i]}

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where( 'agreements.user_id in (select users.id from users where LOWER(users.first_name) LIKE ? or LOWER(users.last_name) LIKE ? or LOWER(users.email) LIKE ? )', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ).references(:users) }

  # Model Validation
  validates_presence_of :dua, :user_id
  validates_presence_of :executed_dua, if: :approved?
  validates_presence_of :comments, if: :resubmission_required?

  # Model Relationships
  belongs_to :user

  # Agreement Methods

  def name
    self.user ? self.user.name : "##{self.id}"
  end

  def approved?
    self.status == 'approved'
  end

  def resubmission_required?
    self.status == 'resubmit' or self.status == 'expired'
  end

  def add_event!(message, current_user, status)
    self.history << { message: message, user_id: current_user.id, event_at: Time.now, status: status }
    self.status = status
    self.save
  end

  def daua_approved_email(current_user)
    self.add_event!('Data Access and Use Agreement approved.', current_user, 'approved')
    UserMailer.daua_approved(self, current_user).deliver if Rails.env.production?
    notify_admins_on_daua_progress(current_user)
  end

  def sent_back_for_resubmission_email(current_user)
    self.add_event!('Data Access and Use Agreement sent back for resubmission.', current_user, 'resubmit')
    UserMailer.sent_back_for_resubmission(self, current_user).deliver if Rails.env.production?
    notify_admins_on_daua_progress(current_user)
  end

  def notify_admins_on_daua_progress(current_user)
    other_admins = User.system_admins.where.not( id: current_user.id )
    other_admins.each do |admin|
      UserMailer.daua_progress_notification(self, admin).deliver if Rails.env.production?
    end
  end

  def daua_submitted
    User.system_admins.each do |system_admin|
      UserMailer.daua_submitted(system_admin, self).deliver if Rails.env.production?
    end
  end
end
