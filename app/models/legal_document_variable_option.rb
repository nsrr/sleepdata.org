# frozen_string_literal: true

# An option for a legal document variable of type radio.
class LegalDocumentVariableOption < ApplicationRecord
  # Relationships
  belongs_to :legal_document
  belongs_to :legal_document_variable

  # Validations
  validates :value, format: { with: /\A[\w\.-]*\Z/ },
                    uniqueness: { scope: :legal_document_variable_id }
end
