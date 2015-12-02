# Allows users to request to have their data hosted on the NSRR
class HostingRequest < ActiveRecord::Base
  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates :user_id, :description, :institution_name, presence: true

  # Model Relationships
  belongs_to :user

  # Model Methods

  def send_email_in_background

  end

  def send_email(generated_password)
    # Sent with
  end
end
