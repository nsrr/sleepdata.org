class AddShortDescriptionToBroadcasts < ActiveRecord::Migration
  def change
    add_column :broadcasts, :short_description, :string
  end
end
