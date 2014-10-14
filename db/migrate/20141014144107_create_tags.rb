class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.string :color
      t.integer :user_id
      t.boolean :deleted

      t.timestamps null: false
    end

    add_index :tags, :user_id
  end
end
