# frozen_string_literal: true

# Stores organization membership and roles.
class OrganizationUser < ApplicationRecord
  # Constants
  REVIEW_ROLES = [
    ["Principal Reviewer", "principal"],
    ["Reviewer", "regular"],
    ["Viewer", "viewer"],
    ["None", "none"]
  ]

  # Concerns
  include Forkable
  include Strippable
  strip :invite_email

  # Validations
  validates :review_role, inclusion: { in: REVIEW_ROLES.collect(&:second) }
  validates :invite_email, presence: true, if: -> { user_id.blank? }
  validates :invite_token, uniqueness: true, allow_nil: true

  # Relationships
  belongs_to :organization
  belongs_to :user, optional: true
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"

  # Methods

  def review_role_name
    REVIEW_ROLES.find { |_, value| value == review_role }&.first
  end

  def send_invite_email_in_background!
    fork_process(:send_invite_email!)
  end

  private

  def send_invite_email!
    set_invite_token
    return if Rails.env.test?

    OrganizationMailer.invitation(self).deliver_now
  end

  def set_invite_token
    return if invite_token.present?
    update invite_token: SecureRandom.hex(12)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    retry
  end
end
