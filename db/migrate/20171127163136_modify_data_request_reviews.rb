class ModifyDataRequestReviews < ActiveRecord::Migration[5.1]
  def change
    add_column :data_request_reviews, :vote_cleared, :boolean, null: false, default: false
    rename_column :data_request_reviews, :agreement_id, :data_request_id
    add_index :data_request_reviews, :vote_cleared
  end
end
