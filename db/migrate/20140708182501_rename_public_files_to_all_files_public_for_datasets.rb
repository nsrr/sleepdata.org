class RenamePublicFilesToAllFilesPublicForDatasets < ActiveRecord::Migration
  def change
    rename_column :datasets, :public_files, :all_files_public
  end
end
