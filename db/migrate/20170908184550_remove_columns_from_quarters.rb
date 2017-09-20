class RemoveColumnsFromQuarters < ActiveRecord::Migration[5.1]
  def change
    remove_column :quarters, :bigint, :bigint, null: false, default: 0
    remove_column :quarters, :regular_files, :bigint, null: false, default: 0
    remove_column :quarters, :regular_file_size, :bigint, null: false, default: 0
    remove_column :quarters, :regular_total_files, :bigint, null: false, default: 0
    remove_column :quarters, :regular_total_file_size, :bigint, null: false, default: 0
  end
end
