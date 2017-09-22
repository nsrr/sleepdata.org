class CreateFinalLegalDocumentPages < ActiveRecord::Migration[5.1]
  def change
    create_table :final_legal_document_pages do |t|
      t.integer :final_legal_document_id
      t.integer :position, null: false, default: 0
      t.boolean :rider, null: false, default: false
      t.string :title
      t.text :content
      t.boolean :deleted, null: false, default: false
      t.timestamps
      t.index [:final_legal_document_id, :position, :rider, :deleted], name: "index_final_legal_doc_pages"
    end
  end
end
