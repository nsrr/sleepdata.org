class RemoveEditorFromDatasetUsers < ActiveRecord::Migration
  def change
    remove_column :dataset_users, :editor, :boolean, null: false, default: false
    add_index :dataset_users, :role
  end
end
