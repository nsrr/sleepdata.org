class AddAutoSubscribeToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :auto_subscribe, :boolean, null: false, default: true
  end
end
