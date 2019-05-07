class RemoveDescriptionFromDatasetFiles < ActiveRecord::Migration[6.0]
  def change
    remove_column :dataset_files, :description, :text
  end
end
