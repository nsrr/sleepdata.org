class RenameCommunityToolsToTools < ActiveRecord::Migration[5.2]
  def change
    rename_table :community_tools, :tools
    rename_table :community_tool_reviews, :tool_reviews
    rename_column :tool_reviews, :community_tool_id, :tool_id
    rename_column :notifications, :community_tool_id, :tool_id
    rename_column :notifications, :community_tool_review_id, :tool_review_id
  end
end
