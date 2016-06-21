class DropToolContributorsTable < ActiveRecord::Migration
  def up
    drop_table :tool_contributors
  end

  def down
    create_table :tool_contributors do |t|
      t.integer :tool_id
      t.integer :user_id

      t.timestamps
    end
  end
end
