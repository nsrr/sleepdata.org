class ChangeAgreementIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :agreements, :id, :bigint

    change_column :agreement_events, :agreement_id, :bigint
    change_column :agreement_tags, :agreement_id, :bigint
    change_column :agreement_transaction_audits, :agreement_id, :bigint
    change_column :agreement_transactions, :agreement_id, :bigint
    change_column :agreement_variables, :agreement_id, :bigint
    change_column :requests, :agreement_id, :bigint
  end

  def down
    change_column :agreements, :id, :integer

    change_column :agreement_events, :agreement_id, :integer
    change_column :agreement_tags, :agreement_id, :integer
    change_column :agreement_transaction_audits, :agreement_id, :integer
    change_column :agreement_transactions, :agreement_id, :integer
    change_column :agreement_variables, :agreement_id, :integer
    change_column :requests, :agreement_id, :integer
  end
end
