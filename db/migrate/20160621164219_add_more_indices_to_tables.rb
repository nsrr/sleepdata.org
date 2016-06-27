class AddMoreIndicesToTables < ActiveRecord::Migration[4.2]
  def change
    add_index :challenges, :slug, unique: true
    add_index :challenges, :public
    add_index :challenges, :deleted
    add_index :dataset_file_audits, :medium
    add_index :dataset_users, :dataset_id
    add_index :dataset_users, :user_id
    add_index :dataset_users, :approved
    add_index :datasets, :user_id
    add_index :datasets, :deleted
    add_index :domain_options, :domain_id
    add_index :domain_options, :position
    add_index :questions, :challenge_id
    add_index :questions, :deleted
    add_index :requests, :agreement_id
    add_index :requests, :dataset_id
    add_index :subscriptions, :subscribed
    add_index :tags, :deleted
    add_index :tool_users, :editor
    add_index :tool_users, :approved
    add_index :tools, :deleted
    add_index :tools, :public
    add_index :users, :emails_enabled
    add_index :users, :aug_member
    add_index :users, :core_member
    add_index :users, :community_manager
    add_index :users, :system_admin
    add_index :users, :deleted
  end
end
