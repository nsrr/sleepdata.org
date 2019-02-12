class ChangeDataRequestIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :data_request_reviews, :data_request_id, :bigint
    change_column :supporting_documents, :data_request_id, :bigint
  end

  def down
    change_column :data_request_reviews, :data_request_id, :integer
    change_column :supporting_documents, :data_request_id, :integer
  end
end
