class ChangeNotificationIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :notifications, :id, :bigint
  end

  def down
    change_column :notifications, :id, :integer
  end
end
