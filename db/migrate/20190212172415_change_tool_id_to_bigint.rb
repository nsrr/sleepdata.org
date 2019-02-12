class ChangeToolIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :tools, :id, :bigint

    change_column :notifications, :tool_id, :bigint
    change_column :tool_reviews, :tool_id, :bigint
  end

  def down
    change_column :tools, :id, :integer

    change_column :notifications, :tool_id, :integer
    change_column :tool_reviews, :tool_id, :integer
  end
end
