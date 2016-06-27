class AddLastCommentAtToTopics < ActiveRecord::Migration[4.2]
  def change
    add_column :topics, :last_comment_at, :datetime
  end
end
