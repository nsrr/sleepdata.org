class AddIndicesToAnswers < ActiveRecord::Migration[4.2]
  def change
    add_index :answers, :challenge_id
    add_index :answers, :question_id
    add_index :answers, :user_id
  end
end
