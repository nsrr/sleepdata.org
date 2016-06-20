class RenameCommentsToReplies < ActiveRecord::Migration
  def change
    rename_table :comments, :replies
  end
end
