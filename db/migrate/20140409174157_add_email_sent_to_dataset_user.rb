class AddEmailSentToDatasetUser < ActiveRecord::Migration
  def change
    add_column :dataset_users, :email_sent, :boolean, null: false, default: false
  end
end
