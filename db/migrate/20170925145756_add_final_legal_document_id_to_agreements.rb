class AddFinalLegalDocumentIdToAgreements < ActiveRecord::Migration[5.1]
  def change
    add_column :agreements, :final_legal_document_id, :integer
    add_index :agreements, :final_legal_document_id
  end
end
