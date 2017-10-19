# frozen_string_literal: true

# Stores PDFs and images attached to data requests.
class SupportingDocument < ApplicationRecord
  # Uploaders
  mount_uploader :document, SupportingDocumentUploader

  # Validations
  validates :document, presence: true

  # Relationships
  belongs_to :data_request
end
