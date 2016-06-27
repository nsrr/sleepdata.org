class DropBroadcastCommentTable < ActiveRecord::Migration
  def up
    remove_index :broadcast_comments, :deleted
    remove_index :broadcast_comments, :broadcast_comment_id
    remove_index :broadcast_comments, :broadcast_id
    remove_index :broadcast_comments, :user_id
    drop_table :broadcast_comments
  end

  def down
    create_table :broadcast_comments do |t|
      t.integer :user_id
      t.text :description
      t.integer :broadcast_id
      t.integer :broadcast_comment_id
      t.boolean :deleted, null: false, default: false
      t.timestamps null: false
    end
    add_index :broadcast_comments, :user_id
    add_index :broadcast_comments, :broadcast_id
    add_index :broadcast_comments, :broadcast_comment_id
    add_index :broadcast_comments, :deleted
  end
end
