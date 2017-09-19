class CreateLegalDocumentDatasets < ActiveRecord::Migration[5.1]
  def change
    create_table :legal_document_datasets do |t|
      t.integer :organization_id
      t.integer :legal_document_id
      t.integer :dataset_id
      t.index :organization_id
      t.index [:legal_document_id, :dataset_id], unique: true, name: "index_legal_doc_datasets"
      t.timestamps
    end
  end
end
