class AddCoverToBroadcasts < ActiveRecord::Migration[5.2]
  def change
    add_column :broadcasts, :cover, :string
  end
end
