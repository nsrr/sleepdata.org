class RenameCommentsToReplies < ActiveRecord::Migration[4.2]
  def change
    rename_table :comments, :replies
  end
end
