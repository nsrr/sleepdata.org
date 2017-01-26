# frozen_string_literal: true

# Allows users to request to have their data hosted on the NSRR
class HostingRequest < ApplicationRecord
  # Concerns
  include Deletable, Forkable, Searchable

  # Named Scopes

  # Model Validation
  validates :user_id, :description, :institution_name, presence: true

  # Model Relationships
  belongs_to :user
  has_many :notifications

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

  def hosting_request_submitted_in_background
    fork_process(:hosting_request_submitted)
  end

  def destroy
    notifications.destroy_all
    super
  end

  protected

  def hosting_request_submitted
    create_notifications!
    UserMailer.hosting_request_submitted(self).deliver_now if EMAILS_ENABLED
  end

  def create_notifications!
    User.system_admins.each do |u|
      notification = u.notifications.where(hosting_request_id: id).first_or_create
      notification.mark_as_unread!
    end
  end
end
