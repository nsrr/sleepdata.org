class ChangeLegalDocumentVariableIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :legal_document_variable_options, :legal_document_variable_id, :bigint
  end

  def down
    change_column :legal_document_variable_options, :legal_document_variable_id, :integer
  end
end
