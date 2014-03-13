class CreateDatasetContributors < ActiveRecord::Migration
  def change
    create_table :dataset_contributors do |t|
      t.integer :dataset_id
      t.integer :user_id

      t.timestamps
    end
  end
end
