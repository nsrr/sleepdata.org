class ChangeTopicUserIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :topic_users, :id, :bigint
  end

  def down
    change_column :topic_users, :id, :integer
  end
end
