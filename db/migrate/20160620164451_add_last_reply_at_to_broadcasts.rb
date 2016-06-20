class AddLastReplyAtToBroadcasts < ActiveRecord::Migration
  def change
    add_column :broadcasts, :last_reply_at, :datetime
    add_index :broadcasts, :last_reply_at
  end
end
