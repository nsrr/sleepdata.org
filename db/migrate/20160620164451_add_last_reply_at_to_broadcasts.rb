class AddLastReplyAtToBroadcasts < ActiveRecord::Migration[4.2]
  def change
    add_column :broadcasts, :last_reply_at, :datetime
    add_index :broadcasts, :last_reply_at
  end
end
