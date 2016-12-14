class AddCommunityToolReviewIdToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :community_tool_id, :integer
    add_index :notifications, :community_tool_id
    add_column :notifications, :community_tool_review_id, :integer
    add_index :notifications, :community_tool_review_id
  end
end
