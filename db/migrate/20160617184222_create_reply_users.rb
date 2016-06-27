class CreateReplyUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :reply_users do |t|
      t.integer :broadcast_id
      t.integer :topic_id
      t.integer :reply_id
      t.integer :user_id
      t.integer :vote, null: false, default: 0

      t.timestamps null: false
    end

    add_index :reply_users, :broadcast_id
    add_index :reply_users, :topic_id
    add_index :reply_users, [:reply_id, :user_id], name: 'index_reply_votes', unique: true
    add_index :reply_users, :vote
  end
end
