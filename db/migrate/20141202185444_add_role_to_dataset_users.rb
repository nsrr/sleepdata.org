class AddRoleToDatasetUsers < ActiveRecord::Migration
  def change
    add_column :dataset_users, :role, :string
  end
end
