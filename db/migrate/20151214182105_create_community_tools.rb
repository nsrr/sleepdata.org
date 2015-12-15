class CreateCommunityTools < ActiveRecord::Migration
  def change
    create_table :community_tools do |t|
      t.string :url
      t.text :description
      t.integer :user_id
      t.string :status, null: false, default: 'started'
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :community_tools, :user_id
    add_index :community_tools, :status
    add_index :community_tools, :deleted
  end
end
