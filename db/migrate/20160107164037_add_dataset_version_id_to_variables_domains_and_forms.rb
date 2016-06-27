class AddDatasetVersionIdToVariablesDomainsAndForms < ActiveRecord::Migration[4.2]
  def change
    add_column :domains, :dataset_version_id, :integer
    add_column :forms, :dataset_version_id, :integer
    add_column :variables, :dataset_version_id, :integer
    add_column :datasets, :dataset_version_id, :integer

    add_index :domains, :dataset_version_id
    add_index :forms, :dataset_version_id
    add_index :variables, :dataset_version_id
    add_index :datasets, :dataset_version_id
  end
end
