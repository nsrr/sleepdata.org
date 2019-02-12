class ChangeFinalLegalDocumentVariableIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :agreement_transaction_audits, :final_legal_document_variable_id, :bigint
    change_column :agreement_variables, :final_legal_document_variable_id, :bigint
    change_column :final_legal_document_variable_options, :final_legal_document_variable_id, :bigint
  end

  def down
    change_column :agreement_transaction_audits, :final_legal_document_variable_id, :integer
    change_column :agreement_variables, :final_legal_document_variable_id, :integer
    change_column :final_legal_document_variable_options, :final_legal_document_variable_id, :integer
  end
end
