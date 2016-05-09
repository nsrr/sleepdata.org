class AddSlugToBroadcasts < ActiveRecord::Migration
  def change
    add_column :broadcasts, :slug, :string
    add_index :broadcasts, :slug, unique: true
  end
end
