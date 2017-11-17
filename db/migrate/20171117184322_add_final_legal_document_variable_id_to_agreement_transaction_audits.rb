class AddFinalLegalDocumentVariableIdToAgreementTransactionAudits < ActiveRecord::Migration[5.1]
  def change
    add_column :agreement_transaction_audits, :final_legal_document_variable_id, :integer
    add_index :agreement_transaction_audits, :final_legal_document_variable_id, name: "index_variable_audit"
  end
end
