class DropAnswersTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :answers do |t|
      t.integer :challenge_id
      t.integer :question_id
      t.integer :user_id
      t.text :response
      t.timestamps
      t.index :challenge_id
      t.index :question_id
      t.index :user_id
    end
  end
end
