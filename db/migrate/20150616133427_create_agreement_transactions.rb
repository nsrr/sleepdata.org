class CreateAgreementTransactions < ActiveRecord::Migration
  def change
    create_table :agreement_transactions do |t|
      t.string :transaction_type
      t.integer :agreement_id
      t.integer :user_id
      t.string :remote_ip

      t.datetime :created_at, null: false
    end

    add_index :agreement_transactions, :agreement_id
    add_index :agreement_transactions, :user_id
  end
end
