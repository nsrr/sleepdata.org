class CreateFinalLegalDocumentVariables < ActiveRecord::Migration[5.1]
  def change
    create_table :final_legal_document_variables do |t|
      t.integer :final_legal_document_id
      t.integer :final_legal_document_page_id
      t.integer :position
      t.string :name
      t.string :display_name
      t.string :variable_type, null: false, default: "string"
      t.text :description
      t.string :field_note
      t.boolean :required, null: false, default: false
      t.boolean :deleted, null: false, default: false
      t.timestamps
      t.index :final_legal_document_id
      t.index :final_legal_document_page_id, name: "index_final_doc_variables_on_page"
      t.index :position
      t.index :deleted
    end
  end
end
