class RenamePublicFilesToAllFilesPublicForDatasets < ActiveRecord::Migration[4.2]
  def change
    rename_column :datasets, :public_files, :all_files_public
  end
end
