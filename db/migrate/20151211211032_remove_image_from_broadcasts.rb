class RemoveImageFromBroadcasts < ActiveRecord::Migration[4.2]
  def change
    remove_column :broadcasts, :image, :string
  end
end
