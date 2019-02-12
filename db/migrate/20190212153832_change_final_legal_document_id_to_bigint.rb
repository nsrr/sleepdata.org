class ChangeFinalLegalDocumentIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :agreements, :final_legal_document_id, :bigint
    change_column :final_legal_document_pages, :final_legal_document_id, :bigint
    change_column :final_legal_document_variable_options, :final_legal_document_id, :bigint
    change_column :final_legal_document_variables, :final_legal_document_id, :bigint
  end

  def down
    change_column :agreements, :final_legal_document_id, :integer
    change_column :final_legal_document_pages, :final_legal_document_id, :integer
    change_column :final_legal_document_variable_options, :final_legal_document_id, :integer
    change_column :final_legal_document_variables, :final_legal_document_id, :integer
  end
end
