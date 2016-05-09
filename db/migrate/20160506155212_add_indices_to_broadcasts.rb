class AddIndicesToBroadcasts < ActiveRecord::Migration
  def change
    add_index :broadcasts, :publish_date
    add_index :broadcasts, :pinned
    add_index :broadcasts, :published
  end
end
