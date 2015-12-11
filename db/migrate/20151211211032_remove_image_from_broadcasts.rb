class RemoveImageFromBroadcasts < ActiveRecord::Migration
  def change
    remove_column :broadcasts, :image, :string
  end
end
