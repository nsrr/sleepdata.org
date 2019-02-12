class ChangeBroadcastIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :broadcasts, :id, :bigint

    change_column :replies, :broadcast_id, :bigint
    change_column :reply_users, :broadcast_id, :bigint
    change_column :notifications, :broadcast_id, :bigint
  end

  def down
    change_column :broadcasts, :id, :integer

    change_column :replies, :broadcast_id, :integer
    change_column :reply_users, :broadcast_id, :integer
    change_column :notifications, :broadcast_id, :integer
  end
end
