class CreateDatasetContributors < ActiveRecord::Migration[4.2]
  def change
    create_table :dataset_contributors do |t|
      t.integer :dataset_id
      t.integer :user_id

      t.timestamps
    end
  end
end
