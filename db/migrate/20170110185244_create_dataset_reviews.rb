class CreateDatasetReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :dataset_reviews do |t|
      t.integer :dataset_id
      t.integer :user_id
      t.integer :rating
      t.text :review
      t.index [:dataset_id, :user_id], unique: true
      t.timestamps
    end
  end
end
