class ChangeTopicIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :topics, :id, :bigint

    change_column :notifications, :topic_id, :bigint
    change_column :replies, :topic_id, :bigint
    change_column :reply_users, :topic_id, :bigint
    change_column :subscriptions, :topic_id, :bigint
    change_column :topic_tags, :topic_id, :bigint
    change_column :topic_users, :topic_id, :bigint
  end

  def down
    change_column :topics, :id, :integer

    change_column :notifications, :topic_id, :integer
    change_column :replies, :topic_id, :integer
    change_column :reply_users, :topic_id, :integer
    change_column :subscriptions, :topic_id, :integer
    change_column :topic_tags, :topic_id, :integer
    change_column :topic_users, :topic_id, :integer
  end
end
