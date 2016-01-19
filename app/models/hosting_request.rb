# Allows users to request to have their data hosted on the NSRR
class HostingRequest < ActiveRecord::Base
  # Concerns
  include Deletable, Forkable

  # Callbacks
  after_create :send_hosting_request_notification

  # Named Scopes

  # Model Validation
  validates :user_id, :description, :institution_name, presence: true

  # Model Relationships
  belongs_to :user

  # Model Methods

  def send_email_in_background
  end

  def send_email(generated_password)
    # Sent with generated_password
  end

  protected

  def send_hosting_request_notification_in_background
    fork_process(:send_hosting_request_notification)
  end

  def send_hosting_request_notification
    UserMailer.hosting_request_submitted(self).deliver_later if EMAILS_ENABLED
  end
end
