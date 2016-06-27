class CreateToolUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :tool_users do |t|
      t.integer :tool_id
      t.integer :user_id
      t.boolean :editor, null: false, default: false
      t.boolean :approved

      t.timestamps
    end
    add_index :tool_users, :tool_id
    add_index :tool_users, :user_id
  end
end
