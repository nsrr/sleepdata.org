class AgreementTransactionAudit < ActiveRecord::Base

  # Model Relationships
  belongs_to :agreement
  belongs_to :agreement_transaction
  belongs_to :user

end
