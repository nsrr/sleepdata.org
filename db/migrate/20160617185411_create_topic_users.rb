class CreateTopicUsers < ActiveRecord::Migration
  def change
    create_table :topic_users do |t|
      t.integer :topic_id
      t.integer :user_id
      t.integer :current_reply_read_id
      t.integer :last_reply_read_id

      t.timestamps null: false
    end
    add_index :topic_users, [:topic_id, :user_id], unique: true
    add_index :topic_users, :current_reply_read_id
    add_index :topic_users, :last_reply_read_id
  end
end
