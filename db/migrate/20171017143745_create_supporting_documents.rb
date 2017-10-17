class CreateSupportingDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :supporting_documents do |t|
      t.integer :data_request_id
      t.string :document
      t.bigint :file_size, default: 0, null: false
      t.timestamps
      t.index :data_request_id
      t.index :file_size
    end
  end
end
