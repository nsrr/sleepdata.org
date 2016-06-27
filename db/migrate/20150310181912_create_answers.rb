class CreateAnswers < ActiveRecord::Migration[4.2]
  def change
    create_table :answers do |t|
      t.integer :challenge_id
      t.integer :question_id
      t.integer :user_id
      t.text :response

      t.timestamps null: false
    end
  end
end
