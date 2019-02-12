class ChangeDatasetFileIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :dataset_files, :id, :bigint
  end

  def down
    change_column :dataset_files, :id, :integer
  end
end
