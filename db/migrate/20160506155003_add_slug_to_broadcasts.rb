class AddSlugToBroadcasts < ActiveRecord::Migration[4.2]
  def change
    add_column :broadcasts, :slug, :string
    add_index :broadcasts, :slug, unique: true
  end
end
