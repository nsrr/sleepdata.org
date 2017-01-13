class AddSeriesToCommunityTools < ActiveRecord::Migration[5.0]
  def change
    add_column :community_tools, :series, :string
  end
end
