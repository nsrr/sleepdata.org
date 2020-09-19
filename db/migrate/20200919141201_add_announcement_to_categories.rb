class AddAnnouncementToCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :announcement, :boolean, null: false, default: false
    add_index :categories, :announcement
  end
end
