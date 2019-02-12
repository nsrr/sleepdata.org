class ChangeToolReviewIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :tool_reviews, :id, :bigint

    change_column :notifications, :tool_review_id, :bigint
  end

  def down
    change_column :tool_reviews, :id, :integer

    change_column :notifications, :tool_review_id, :integer
  end
end
