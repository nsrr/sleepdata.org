class AddDisableDatasetRequestsToDataset < ActiveRecord::Migration[6.1]
  def change
    add_column :datasets, :disable_data_requests, :boolean, null: false, default: false
    add_index :datasets, :disable_data_requests
  end
end
