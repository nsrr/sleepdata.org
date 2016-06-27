class AddViewCountToBroadcasts < ActiveRecord::Migration[4.2]
  def change
    add_column :broadcasts, :view_count, :integer, null: false, default: 0
    add_index :broadcasts, :view_count
  end
end
