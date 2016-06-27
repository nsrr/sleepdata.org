class AddEmailSentToDatasetUser < ActiveRecord::Migration[4.2]
  def change
    add_column :dataset_users, :email_sent, :boolean, null: false, default: false
  end
end
