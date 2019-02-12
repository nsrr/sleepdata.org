class ChangeUserIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :id, :bigint

    change_column :agreement_events, :user_id, :bigint
    change_column :agreement_transaction_audits, :user_id, :bigint
    change_column :agreement_transactions, :user_id, :bigint
    change_column :agreements, :user_id, :bigint
    change_column :broadcasts, :user_id, :bigint
    change_column :data_request_reviews, :user_id, :bigint
    change_column :dataset_file_audits, :user_id, :bigint
    change_column :dataset_page_audits, :user_id, :bigint
    change_column :dataset_reviews, :user_id, :bigint
    change_column :dataset_users, :user_id, :bigint
    change_column :datasets, :user_id, :bigint
    change_column :exports, :user_id, :bigint
    change_column :images, :user_id, :bigint
    change_column :notifications, :user_id, :bigint
    change_column :organization_users, :user_id, :bigint
    change_column :replies, :user_id, :bigint
    change_column :reply_users, :user_id, :bigint
    change_column :subscriptions, :user_id, :bigint
    change_column :tags, :user_id, :bigint
    change_column :tool_reviews, :user_id, :bigint
    change_column :tools, :user_id, :bigint
    change_column :topic_users, :user_id, :bigint
    change_column :topics, :user_id, :bigint
  end

  def down
    change_column :users, :id, :integer

    change_column :agreement_events, :user_id, :integer
    change_column :agreement_transaction_audits, :user_id, :integer
    change_column :agreement_transactions, :user_id, :integer
    change_column :agreements, :user_id, :integer
    change_column :broadcasts, :user_id, :integer
    change_column :data_request_reviews, :user_id, :integer
    change_column :dataset_file_audits, :user_id, :integer
    change_column :dataset_page_audits, :user_id, :integer
    change_column :dataset_reviews, :user_id, :integer
    change_column :dataset_users, :user_id, :integer
    change_column :datasets, :user_id, :integer
    change_column :exports, :user_id, :integer
    change_column :images, :user_id, :integer
    change_column :notifications, :user_id, :integer
    change_column :organization_users, :user_id, :integer
    change_column :replies, :user_id, :integer
    change_column :reply_users, :user_id, :integer
    change_column :subscriptions, :user_id, :integer
    change_column :tags, :user_id, :integer
    change_column :tool_reviews, :user_id, :integer
    change_column :tools, :user_id, :integer
    change_column :topic_users, :user_id, :integer
    change_column :topics, :user_id, :integer
  end
end
