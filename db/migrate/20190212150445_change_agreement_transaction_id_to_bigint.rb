class ChangeAgreementTransactionIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :agreement_transactions, :id, :bigint

    change_column :agreement_transaction_audits, :agreement_transaction_id, :bigint
  end

  def down
    change_column :agreement_transactions, :id, :integer

    change_column :agreement_transaction_audits, :agreement_transaction_id, :integer
  end
end
