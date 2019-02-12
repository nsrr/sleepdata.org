class ChangeExtraKeysToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :organization_users, :creator_id, :bigint
    change_column :pg_search_documents, :searchable_id, :bigint
    change_column :topic_users, :current_reply_read_id, :bigint
    change_column :topic_users, :last_reply_read_id, :bigint
  end

  def down
    change_column :organization_users, :creator_id, :integer
    change_column :pg_search_documents, :searchable_id, :integer
    change_column :topic_users, :current_reply_read_id, :integer
    change_column :topic_users, :last_reply_read_id, :integer
  end
end
