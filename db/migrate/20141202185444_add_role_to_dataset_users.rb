class AddRoleToDatasetUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :dataset_users, :role, :string
  end
end
