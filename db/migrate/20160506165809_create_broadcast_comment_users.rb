class CreateBroadcastCommentUsers < ActiveRecord::Migration
  def change
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
