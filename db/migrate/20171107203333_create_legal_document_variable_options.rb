class CreateLegalDocumentVariableOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :legal_document_variable_options do |t|
      t.integer :legal_document_id
      t.integer :legal_document_variable_id
      t.integer :position
      t.string :display_name
      t.string :value
      t.index :legal_document_id
      t.index [:legal_document_variable_id, :position], name: "index_legal_doc_variable_options"
      t.timestamps
    end
  end
end
