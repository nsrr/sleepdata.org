class AddViewCountIndexToTopics < ActiveRecord::Migration
  def change
    add_index :topics, :view_count
  end
end
