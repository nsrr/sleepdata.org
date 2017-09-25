class CreateAgreementVariables < ActiveRecord::Migration[5.1]
  def change
    create_table :agreement_variables do |t|
      t.integer :agreement_id
      t.integer :final_legal_document_variable_id
      t.text :value
      t.timestamps
      t.index [:agreement_id, :final_legal_document_variable_id], name: "index_agreement_variable_values", unique: true
    end
  end
end
