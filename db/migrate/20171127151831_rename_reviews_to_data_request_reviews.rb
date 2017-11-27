class RenameReviewsToDataRequestReviews < ActiveRecord::Migration[5.1]
  def change
    rename_table :reviews, :data_request_reviews
  end
end
