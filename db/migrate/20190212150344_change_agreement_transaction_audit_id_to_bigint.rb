class ChangeAgreementTransactionAuditIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :agreement_transaction_audits, :id, :bigint
  end

  def down
    change_column :agreement_transaction_audits, :id, :integer
  end
end
