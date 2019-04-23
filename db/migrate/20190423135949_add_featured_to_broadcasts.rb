class AddFeaturedToBroadcasts < ActiveRecord::Migration[6.0]
  def change
    add_column :broadcasts, :featured, :boolean, null: false, default: false
    add_index :broadcasts, :featured
  end
end
