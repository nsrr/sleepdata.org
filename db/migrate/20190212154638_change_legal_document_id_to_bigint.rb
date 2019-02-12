class ChangeLegalDocumentIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :final_legal_documents, :legal_document_id, :bigint
    change_column :legal_document_datasets, :legal_document_id, :bigint
    change_column :legal_document_pages, :legal_document_id, :bigint
    change_column :legal_document_variable_options, :legal_document_id, :bigint
    change_column :legal_document_variables, :legal_document_id, :bigint
  end

  def down
    change_column :final_legal_documents, :legal_document_id, :integer
    change_column :legal_document_datasets, :legal_document_id, :integer
    change_column :legal_document_pages, :legal_document_id, :integer
    change_column :legal_document_variable_options, :legal_document_id, :integer
    change_column :legal_document_variables, :legal_document_id, :integer
  end
end
