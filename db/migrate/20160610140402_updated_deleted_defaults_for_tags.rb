class UpdatedDeletedDefaultsForTags < ActiveRecord::Migration
  def up
    change_column :tags, :deleted, :boolean, null: false, default: false
  end

  def down
    change_column :tags, :deleted, :boolean, null: true, default: nil
  end
end
