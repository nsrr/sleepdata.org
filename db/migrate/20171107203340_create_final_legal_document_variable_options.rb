class CreateFinalLegalDocumentVariableOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :final_legal_document_variable_options do |t|
      t.integer :final_legal_document_id
      t.integer :final_legal_document_variable_id
      t.integer :position
      t.string :display_name
      t.string :value
      t.index :final_legal_document_id, name: "index_final_legal_doc_variable_options"
      t.index [:final_legal_document_variable_id, :position], name: "index_final_legal_doc_variable_opt_pos"
      t.timestamps
    end
  end
end
