class RemoveInfoSizeFromDatasets < ActiveRecord::Migration[5.1]
  def change
    remove_column :datasets, :info_size, :bigint, null: false, default: 0
  end
end
