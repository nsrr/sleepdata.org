class ChangeDatasetReviewIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :dataset_reviews, :id, :bigint

    change_column :notifications, :dataset_review_id, :bigint
  end

  def down
    change_column :dataset_reviews, :id, :integer

    change_column :notifications, :dataset_review_id, :integer
  end
end
