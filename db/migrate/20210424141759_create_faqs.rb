class CreateFaqs < ActiveRecord::Migration[6.1]
  def change
    create_table :faqs do |t|
      t.text :question
      t.text :answer
      t.integer :position
      t.boolean :displayed, null: false, default: true
      t.boolean :deleted, null: false, default: false
      t.timestamps

      t.index :position
      t.index :displayed
      t.index :deleted
    end
  end
end
