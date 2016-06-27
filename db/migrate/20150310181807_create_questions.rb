class CreateQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :questions do |t|
      t.integer :challenge_id
      t.string :name
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end
  end
end
