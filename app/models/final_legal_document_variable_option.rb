
# frozen_string_literal: true

# An option for a final legal document variable of type radio. Not editable.
class FinalLegalDocumentVariableOption < ApplicationRecord
  # Relationships
  belongs_to :final_legal_document
  belongs_to :final_legal_document_variable

  # Validations
  validates :value, format: { with: /\A[\w\.-]*\Z/ },
                    uniqueness: { scope: :final_legal_document_variable_id }
end
