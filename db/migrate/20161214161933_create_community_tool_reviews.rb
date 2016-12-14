class CreateCommunityToolReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :community_tool_reviews do |t|
      t.integer :community_tool_id
      t.integer :user_id
      t.integer :rating
      t.text :review
      t.index [:community_tool_id, :user_id], unique: true
      t.timestamps
    end
  end
end
