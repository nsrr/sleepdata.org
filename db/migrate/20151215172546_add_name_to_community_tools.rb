class AddNameToCommunityTools < ActiveRecord::Migration
  def change
    add_column :community_tools, :name, :string
  end
end
