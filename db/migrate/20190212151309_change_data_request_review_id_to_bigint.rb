class ChangeDataRequestReviewIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :data_request_reviews, :id, :bigint
  end

  def down
    change_column :data_request_reviews, :id, :integer
  end
end
