class AddEmailMeWhenMentionedToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :email_me_when_mentioned, :boolean, null: false, default: true
  end
end
