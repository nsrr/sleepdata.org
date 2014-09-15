class AddAutoSubscribeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auto_subscribe, :boolean, null: false, default: true
  end
end
