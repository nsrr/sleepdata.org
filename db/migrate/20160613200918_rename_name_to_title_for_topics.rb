class RenameNameToTitleForTopics < ActiveRecord::Migration[4.2]
  def change
    rename_column :topics, :name, :title
  end
end
