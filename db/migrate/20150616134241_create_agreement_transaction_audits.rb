class CreateAgreementTransactionAudits < ActiveRecord::Migration
  def change
    create_table :agreement_transaction_audits do |t|
      t.integer :agreement_transaction_id
      t.integer :user_id
      t.integer :agreement_id
      t.string :agreement_attribute_name
      t.text :value_before
      t.text :value_after

      t.datetime :created_at, null: false
    end

    add_index :agreement_transaction_audits, :agreement_transaction_id
    add_index :agreement_transaction_audits, :user_id
    add_index :agreement_transaction_audits, :agreement_id
  end
end
