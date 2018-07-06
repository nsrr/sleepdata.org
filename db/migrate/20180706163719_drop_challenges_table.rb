class DropChallengesTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :challenges do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.integer :user_id
      t.boolean :public, default: true, null: false
      t.boolean :deleted, default: false, null: false
      t.string :survey_url
      t.timestamps
      t.index :deleted
      t.index :public
      t.index :slug, unique: true
      t.index :user_id
    end
  end
end
