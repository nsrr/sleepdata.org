class CommunityTool < ActiveRecord::Base
  # Constants
  STATUS = %w(submitted accepted rejected)

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates :user_id, :url, :description, :status, presence: true

  # Model Relationships
  belongs_to :user

  # Community Tool Methods

  def name
    "Tool ##{id}"
  end
end
