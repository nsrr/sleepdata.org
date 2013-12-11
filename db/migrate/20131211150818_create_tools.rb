class CreateTools < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.string :name
      t.text :description
      t.string :slug
      t.string :logo
      t.integer :user_id
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end

    add_index :tools, :slug, unique: true
    add_index :tools, :user_id
  end
end
