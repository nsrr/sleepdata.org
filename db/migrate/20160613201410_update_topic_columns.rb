class UpdateTopicColumns < ActiveRecord::Migration[4.2]
  def up
    rename_column :topics, :stickied, :pinned
    rename_column :topics, :last_comment_at, :last_reply_at
    add_column :topics, :slug, :string
    add_column :topics, :view_count, :integer, null: false, default: 0
    add_index :topics, :slug, unique: true
    add_index :topics, :user_id
    add_index :topics, :pinned
    add_index :topics, :locked
    add_index :topics, :last_reply_at
    add_index :topics, :deleted
  end

  def down
    remove_index :topics, :deleted
    remove_index :topics, :last_reply_at
    remove_index :topics, :locked
    remove_index :topics, :pinned
    remove_index :topics, :user_id
    remove_index :topics, :slug
    remove_column :topics, :view_count
    remove_column :topics, :slug
    rename_column :topics, :last_reply_at, :last_comment_at
    rename_column :topics, :pinned, :stickied
  end
end
