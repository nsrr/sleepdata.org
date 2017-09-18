class CreateLegalDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :legal_documents do |t|
      t.integer :organization_id
      t.string :name
      t.string :slug
      t.string :commercial_type, null: false, default: "both"
      t.string :data_user_type, null: false, default: "both"
      t.string :attestation_type, null: false, default: "none"
      t.string :approval_process, null: false, default: "immediate"
      t.boolean :deleted, null: false, default: false
      t.index :organization_id
      t.index :slug
      t.index :deleted
      t.timestamps
    end
  end
end
