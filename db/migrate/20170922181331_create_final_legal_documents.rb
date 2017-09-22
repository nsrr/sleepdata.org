class CreateFinalLegalDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :final_legal_documents do |t|
      t.integer :organization_id
      t.integer :legal_document_id
      t.string :name
      t.string :slug
      t.string :commercial_type, null: false, default: "both"
      t.string :data_user_type, null: false, default: "both"
      t.string :attestation_type, null: false, default: "none"
      t.string :approval_process, null: false, default: "immediate"
      t.integer :version_major, null: false, default: 0
      t.integer :version_minor, null: false, default: 0
      t.integer :version_tiny, null: false, default: 0
      t.string :version_build
      t.string :version_md5
      t.datetime :published_at
      t.boolean :deleted, null: false, default: false
      t.index :organization_id
      t.index :slug
      t.index [:legal_document_id, :published_at, :deleted], name: "index_final_legal_docs"
      t.timestamps
    end
  end
end
