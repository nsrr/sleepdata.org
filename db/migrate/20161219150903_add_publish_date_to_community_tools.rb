class AddPublishDateToCommunityTools < ActiveRecord::Migration[5.0]
  def change
    add_column :community_tools, :publish_date, :date
    add_index :community_tools, :publish_date
  end
end
