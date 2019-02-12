class ChangeDatasetVersionIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :dataset_versions, :id, :bigint

    change_column :datasets, :dataset_version_id, :bigint
    change_column :domains, :dataset_version_id, :bigint
    change_column :forms, :dataset_version_id, :bigint
    change_column :variables, :dataset_version_id, :bigint
  end

  def down
    change_column :dataset_versions, :id, :integer

    change_column :datasets, :dataset_version_id, :integer
    change_column :domains, :dataset_version_id, :integer
    change_column :forms, :dataset_version_id, :integer
    change_column :variables, :dataset_version_id, :integer
  end
end
