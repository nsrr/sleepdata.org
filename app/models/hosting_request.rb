# frozen_string_literal: true

# Allows users to request to have their data hosted on the NSRR
class HostingRequest < ApplicationRecord
  # Concerns
  include Deletable, Forkable, Searchable

  # Callbacks
  after_create_commit :send_hosting_request_notification_in_background

  # Named Scopes

  # Model Validation
  validates :user_id, :description, :institution_name, presence: true

  # Model Relationships
  belongs_to :user

  # Model Methods
  def self.searchable_attributes
    %w(institution_name description)
  end

  def name
    "Hosting Request ID ##{id}"
  end

  def name_was
    name
  end

  def send_email_in_background
    # Blank...
  end

  def send_email(generated_password)
    # Sent with generated_password
  end

  protected

  def send_hosting_request_notification_in_background
    fork_process(:send_hosting_request_notification)
  end

  def send_hosting_request_notification
    UserMailer.hosting_request_submitted(self).deliver_now if EMAILS_ENABLED
  end
end
