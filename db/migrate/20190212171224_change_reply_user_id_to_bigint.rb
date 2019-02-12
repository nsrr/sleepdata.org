class ChangeReplyUserIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :reply_users, :id, :bigint
  end

  def down
    change_column :reply_users, :id, :integer
  end
end
