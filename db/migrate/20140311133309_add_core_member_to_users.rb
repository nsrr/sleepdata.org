class AddCoreMemberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :core_member, :boolean, null: false, default: false
  end
end
