# frozen_string_literal: true

class AgreementTransactionAudit < ApplicationRecord
  # Relationships
  belongs_to :agreement
  belongs_to :agreement_transaction
  belongs_to :user, optional: true
end
