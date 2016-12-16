class AddPublishedToCommunityTools < ActiveRecord::Migration[5.0]
  def change
    add_column :community_tools, :published, :boolean, null: false, default: false
    add_index :community_tools, :published
  end
end
