class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :agreement_id
      t.integer :user_id
      t.boolean :approved

      t.timestamps null: false
    end

    add_index :reviews, :agreement_id
    add_index :reviews, :user_id
  end
end
