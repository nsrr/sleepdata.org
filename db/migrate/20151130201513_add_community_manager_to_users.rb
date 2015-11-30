class AddCommunityManagerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :community_manager, :boolean, null: false, default: false
  end
end
