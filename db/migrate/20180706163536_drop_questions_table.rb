class DropQuestionsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :questions do |t|
      t.integer :challenge_id
      t.string :name
      t.boolean :deleted, default: false, null: false
      t.timestamps
      t.index :challenge_id
      t.index :deleted
    end
  end
end
