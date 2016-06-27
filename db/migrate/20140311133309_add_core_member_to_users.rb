class AddCoreMemberToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :core_member, :boolean, null: false, default: false
  end
end
