class AddProfileReviewToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :profile_reviewed, :boolean, null: false, default: false
    add_index :users, :profile_reviewed
  end
end
