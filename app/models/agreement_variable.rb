# frozen_string_literal: true

# Stores a response on an agreement
class AgreementVariable < ApplicationRecord
  # Concerns
  include Strippable

  strip :value

  # Validations
  validates :agreement_id, uniqueness: { scope: :final_legal_document_variable_id }

  # Relationships
  belongs_to :agreement
  belongs_to :final_legal_document_variable
end
