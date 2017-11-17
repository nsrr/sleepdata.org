# frozen_string_literal: true

class AgreementTransactionAudit < ApplicationRecord
  # Relationships
  belongs_to :agreement
  belongs_to :agreement_transaction
  belongs_to :user, optional: true
  belongs_to :final_legal_document_variable, optional: true
end
