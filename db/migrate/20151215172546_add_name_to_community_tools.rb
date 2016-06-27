class AddNameToCommunityTools < ActiveRecord::Migration[4.2]
  def change
    add_column :community_tools, :name, :string
  end
end
