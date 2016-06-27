class CreateDatasetVersions < ActiveRecord::Migration[4.2]
  def change
    create_table :dataset_versions do |t|
      t.integer :dataset_id
      t.string :version
      t.string :commit
      t.date :release_date
      t.text :release_notes

      t.timestamps null: false
    end

    add_index :dataset_versions, :dataset_id
  end
end
