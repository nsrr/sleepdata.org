class ChangeFinalLegalDocumentPageIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :final_legal_document_variables, :final_legal_document_page_id, :bigint
  end

  def down
    change_column :final_legal_document_variables, :final_legal_document_page_id, :integer
  end
end
