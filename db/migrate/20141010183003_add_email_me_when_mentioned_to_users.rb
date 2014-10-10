class AddEmailMeWhenMentionedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_me_when_mentioned, :boolean, null: false, default: true
  end
end
