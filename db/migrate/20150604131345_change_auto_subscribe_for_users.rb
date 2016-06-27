class ChangeAutoSubscribeForUsers < ActiveRecord::Migration[4.2]
  def up
    change_column :users, :auto_subscribe, :boolean, null: false, default: false
  end

  def down
    change_column :users, :auto_subscribe, :boolean, null: false, default: true
  end
end
