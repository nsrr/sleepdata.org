class ChangeOrganizationIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :datasets, :organization_id, :bigint
    change_column :exports, :organization_id, :bigint
    change_column :final_legal_documents, :organization_id, :bigint
    change_column :legal_document_datasets, :organization_id, :bigint
    change_column :legal_documents, :organization_id, :bigint
    change_column :notifications, :organization_id, :bigint
    change_column :organization_users, :organization_id, :bigint
  end

  def down
    change_column :datasets, :organization_id, :integer
    change_column :exports, :organization_id, :integer
    change_column :final_legal_documents, :organization_id, :integer
    change_column :legal_document_datasets, :organization_id, :integer
    change_column :legal_documents, :organization_id, :integer
    change_column :notifications, :organization_id, :integer
    change_column :organization_users, :organization_id, :integer
  end
end
