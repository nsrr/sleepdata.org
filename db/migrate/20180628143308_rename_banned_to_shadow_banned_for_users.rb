class RenameBannedToShadowBannedForUsers < ActiveRecord::Migration[5.2]
  def up
    rename_column :users, :banned, :shadow_banned
    change_column :users, :shadow_banned, :boolean, null: true, default: nil
    add_index :users, :shadow_banned
  end

  def down
    remove_index :users, :shadow_banned
    change_column :users, :shadow_banned, :boolean, null: false, default: false
    rename_column :users, :shadow_banned, :banned
  end
end
