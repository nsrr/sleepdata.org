class RenamePublicToReleasedForDatasets < ActiveRecord::Migration[5.1]
  def up
    rename_column :datasets, :public, :released
    change_column :datasets, :released, :boolean, null: false, default: false
  end

  def down
    change_column :datasets, :released, :boolean, null: false, default: true
    rename_column :datasets, :released, :public
  end
end
