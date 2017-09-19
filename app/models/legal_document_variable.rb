# frozen_string_literal: true

# Defines data collected in legal document.
class LegalDocumentVariable < ApplicationRecord
  # Constants
  VARIABLE_TYPES = [
    ["String", "string"],
    ["Text", "text"],
    ["Check box", "check_box"],
    ["Radio", "radio"]
  ]

  # Concerns
  include Deletable

  # Validations
  validates :name, :variable_type, presence: true
  validates :name,
            format: { with: /\A[a-z]\w*\Z/i },
            length: { maximum: 32 },
            exclusion: { in: %w(new edit create update destroy overlap null) }
  validates :variable_type, inclusion: { in: VARIABLE_TYPES.collect(&:second) }

  # Relationships
  belongs_to :legal_document
  # belongs_to :legal_document_page

  def legal_document_page
    legal_document.legal_document_pages.find_by("content LIKE ?", "%\#{#{id}}%")
  end

  def variable_type_name
    VARIABLE_TYPES.find { |_name, value| value == variable_type }.first
  end
end
