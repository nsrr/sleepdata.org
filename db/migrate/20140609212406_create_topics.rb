class CreateTopics < ActiveRecord::Migration[4.2]
  def change
    create_table :topics do |t|
      t.string :name
      t.integer :user_id
      t.boolean :stickied, null: false, default: false
      t.boolean :locked, null: false, default: false
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
