class AddOrganizationIdToDatasets < ActiveRecord::Migration[5.1]
  def change
    add_column :datasets, :organization_id, :integer
    add_index :datasets, :organization_id
  end
end
