class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.integer :user_id
      t.boolean :public, null: false, default: true
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :challenges, :user_id
  end
end
