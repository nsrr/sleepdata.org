class AddDatasetReviewIdToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :dataset_id, :integer
    add_index :notifications, :dataset_id
    add_column :notifications, :dataset_review_id, :integer
    add_index :notifications, :dataset_review_id
  end
end
