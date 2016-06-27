class AddCommunityManagerToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :community_manager, :boolean, null: false, default: false
  end
end
