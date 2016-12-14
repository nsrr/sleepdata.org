class AddSlugToCommunityTools < ActiveRecord::Migration[5.0]
  def change
    add_column :community_tools, :slug, :string
    add_index :community_tools, :slug, unique: true
  end
end
