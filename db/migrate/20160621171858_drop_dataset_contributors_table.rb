class DropDatasetContributorsTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :dataset_contributors
  end

  def down
    create_table :dataset_contributors do |t|
      t.integer :dataset_id
      t.integer :user_id

      t.timestamps
    end
  end
end
