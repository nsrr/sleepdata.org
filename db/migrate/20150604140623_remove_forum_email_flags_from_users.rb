class RemoveForumEmailFlagsFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :auto_subscribe, null: false, default: false
    remove_column :users, :email_me_when_mentioned, null: false, default: true
  end
end
