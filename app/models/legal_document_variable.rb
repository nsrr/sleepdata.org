# frozen_string_literal: true

# Defines data collected in legal document.
class LegalDocumentVariable < ApplicationRecord
  # Constants
  VARIABLE_TYPES = [
    ["string", "string"],
    ["text", "text"],
    ["check_box", "check_box"]
  ]

  # Concerns
  include Deletable

  # Validations
  validates :name, :variable_type, presence: true
  validates :variable_type, inclusion: { in: VARIABLE_TYPES.collect(&:second) }

  # Relationships
  belongs_to :legal_document
  belongs_to :legal_document_page
end
