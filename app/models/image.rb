# frozen_string_literal: true

# Encapsulate blog and forum embedded images.
class Image < ApplicationRecord
  # Uploaders
  mount_uploader :image, ResizableImageUploader

  # Concerns
  include Hashable

  # Validations
  validates :user_id, :image, presence: true

  # Relationships
  belongs_to :user

  # Methods

  def name
    image_identifier
  end
end
