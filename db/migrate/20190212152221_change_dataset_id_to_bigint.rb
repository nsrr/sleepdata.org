class ChangeDatasetIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :datasets, :id, :bigint

    change_column :agreement_event_datasets, :dataset_id, :bigint
    change_column :dataset_file_audits, :dataset_id, :bigint
    change_column :dataset_files, :dataset_id, :bigint
    change_column :dataset_page_audits, :dataset_id, :bigint
    change_column :dataset_reviews, :dataset_id, :bigint
    change_column :dataset_users, :dataset_id, :bigint
    change_column :dataset_versions, :dataset_id, :bigint
    change_column :domains, :dataset_id, :bigint
    change_column :forms, :dataset_id, :bigint
    change_column :legal_document_datasets, :dataset_id, :bigint
    change_column :notifications, :dataset_id, :bigint
    change_column :requests, :dataset_id, :bigint
    change_column :variable_forms, :dataset_id, :bigint
    change_column :variables, :dataset_id, :bigint
  end

  def down
    change_column :datasets, :id, :integer

    change_column :agreement_event_datasets, :dataset_id, :integer
    change_column :dataset_file_audits, :dataset_id, :integer
    change_column :dataset_files, :dataset_id, :integer
    change_column :dataset_page_audits, :dataset_id, :integer
    change_column :dataset_reviews, :dataset_id, :integer
    change_column :dataset_users, :dataset_id, :integer
    change_column :dataset_versions, :dataset_id, :integer
    change_column :domains, :dataset_id, :integer
    change_column :forms, :dataset_id, :integer
    change_column :legal_document_datasets, :dataset_id, :integer
    change_column :notifications, :dataset_id, :integer
    change_column :requests, :dataset_id, :integer
    change_column :variable_forms, :dataset_id, :integer
    change_column :variables, :dataset_id, :integer
  end
end
