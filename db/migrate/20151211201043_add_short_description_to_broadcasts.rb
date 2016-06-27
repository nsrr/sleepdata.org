class AddShortDescriptionToBroadcasts < ActiveRecord::Migration[4.2]
  def change
    add_column :broadcasts, :short_description, :string
  end
end
