class ChangeDatasetUserIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :dataset_users, :id, :bigint
  end

  def down
    change_column :dataset_users, :id, :integer
  end
end
