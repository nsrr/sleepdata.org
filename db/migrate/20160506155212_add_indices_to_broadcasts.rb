class AddIndicesToBroadcasts < ActiveRecord::Migration[4.2]
  def change
    add_index :broadcasts, :publish_date
    add_index :broadcasts, :pinned
    add_index :broadcasts, :published
  end
end
