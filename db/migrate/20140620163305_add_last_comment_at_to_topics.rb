class AddLastCommentAtToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :last_comment_at, :datetime
  end
end
