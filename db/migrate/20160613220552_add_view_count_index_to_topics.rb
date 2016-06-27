class AddViewCountIndexToTopics < ActiveRecord::Migration[4.2]
  def change
    add_index :topics, :view_count
  end
end
