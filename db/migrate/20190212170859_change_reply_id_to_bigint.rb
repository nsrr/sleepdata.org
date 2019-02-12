class ChangeReplyIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :replies, :id, :bigint

    change_column :notifications, :reply_id, :bigint
    change_column :replies, :reply_id, :bigint
    change_column :reply_users, :reply_id, :bigint
  end

  def down
    change_column :replies, :id, :integer

    change_column :notifications, :reply_id, :integer
    change_column :replies, :reply_id, :integer
    change_column :reply_users, :reply_id, :integer
  end
end
