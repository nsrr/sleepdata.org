class AddPublicFilesToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :public_files, :boolean, null: false, default: true
  end
end
