# frozen_string_literal: true

class AgreementTransactionAudit < ApplicationRecord

  # Model Relationships
  belongs_to :agreement
  belongs_to :agreement_transaction
  belongs_to :user

end
