# frozen_string_literal: true

# Encapsulate blog and forum embedded images
class Image < ActiveRecord::Base
  # Uploaders
  mount_uploader :image, ResizableImageUploader

  # Concerns
  include Hashable

  # Model Validation
  validates :user_id, :image, presence: true

  # Model Relationships
  belongs_to :user

  # Model Methods

  def name
    image_identifier
  end
end
