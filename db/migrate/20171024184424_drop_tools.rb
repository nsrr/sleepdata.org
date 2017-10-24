class DropTools < ActiveRecord::Migration[5.1]
  def change
    drop_table :tool_users do |t|
      t.integer :tool_id
      t.integer :user_id
      t.boolean :editor, null: false, default: false
      t.boolean :approved
      t.timestamps
      t.index :approved
      t.index :editor
      t.index :tool_id
      t.index :user_id
    end

    drop_table :tools do |t|
      t.string :name
      t.text :description
      t.string :slug
      t.string :logo
      t.integer :user_id
      t.string :tool_type
      t.string :git_repository
      t.boolean :public, null: false, default: true
      t.boolean :deleted, null: false, default: false
      t.timestamps
      t.index :deleted
      t.index :public
      t.index :slug, unique: true
      t.index :user_id
    end
  end
end
