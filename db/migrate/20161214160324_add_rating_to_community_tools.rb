class AddRatingToCommunityTools < ActiveRecord::Migration[5.0]
  def change
    add_column :community_tools, :rating, :float
    add_index :community_tools, :rating
  end
end
