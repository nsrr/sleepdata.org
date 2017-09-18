class CreateLegalDocumentPages < ActiveRecord::Migration[5.1]
  def change
    create_table :legal_document_pages do |t|
      t.integer :legal_document_id
      t.integer :position
      t.boolean :rider, null: false, default: false
      t.string :title
      t.text :content
      t.boolean :deleted, null: false, default: false
      t.index [:legal_document_id, :position, :rider, :deleted], name: "index_legal_doc_pages"
      t.timestamps
    end
  end
end
