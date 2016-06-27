class AddPublicFilesToDatasets < ActiveRecord::Migration[4.2]
  def change
    add_column :datasets, :public_files, :boolean, null: false, default: true
  end
end
