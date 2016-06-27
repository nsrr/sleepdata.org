class DropBroadcastCommentUserTable < ActiveRecord::Migration[4.2]
  def up
    remove_index :broadcast_comment_users, :vote
    remove_index :broadcast_comment_users, name: 'index_blog_comment_votes'
    remove_index :broadcast_comment_users, :broadcast_id
    drop_table :broadcast_comment_users
  end

  def down
    create_table :broadcast_comment_users do |t|
      t.integer :broadcast_id
      t.integer :broadcast_comment_id
      t.integer :user_id
      t.integer :vote, null: false, default: 0
      t.timestamps null: false
    end
    add_index :broadcast_comment_users, :broadcast_id
    add_index :broadcast_comment_users, [:broadcast_comment_id, :user_id], name: 'index_blog_comment_votes', unique: true
    add_index :broadcast_comment_users, :vote
  end
end
