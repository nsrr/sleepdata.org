class AddFolderIdToPages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :folder_id, :bigint
    add_index :pages, :folder_id
  end
end
