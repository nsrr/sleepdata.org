class RemoveAllFilesPublicFromDatasets < ActiveRecord::Migration[5.1]
  def change
    remove_column :datasets, :all_files_public, :boolean, default: true, null: false
  end
end
