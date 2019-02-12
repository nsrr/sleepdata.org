class ChangeLegalDocumentPageIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :legal_document_variables, :legal_document_page_id, :bigint
  end

  def down
    change_column :legal_document_variables, :legal_document_page_id, :integer
  end
end
