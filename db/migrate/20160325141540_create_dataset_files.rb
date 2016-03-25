class CreateDatasetFiles < ActiveRecord::Migration
  def change
    create_table :dataset_files do |t|
      t.integer :dataset_id
      t.text :full_path, null: false, default: ''
      t.text :folder, null: false, default: ''
      t.text :file_name, null: false, default: ''
      t.boolean :is_file, null: false, default: true
      t.integer :file_size, limit: 8, null: false, default: 0
      t.datetime :file_time
      t.string :file_checksum_md5
      t.datetime :checksum_md5_generated_at
      t.boolean :publicly_available, null: false, default: false
      t.boolean :archived, null: false, default: false
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :dataset_files, [:dataset_id, :full_path, :is_file], unique: true
    add_index :dataset_files, :dataset_id
    add_index :dataset_files, :full_path
    add_index :dataset_files, :folder
    add_index :dataset_files, :file_name
    add_index :dataset_files, :is_file
    add_index :dataset_files, :file_size
    add_index :dataset_files, :file_time
    add_index :dataset_files, :file_checksum_md5
    add_index :dataset_files, :checksum_md5_generated_at
    add_index :dataset_files, :publicly_available
    add_index :dataset_files, :archived
    add_index :dataset_files, :deleted
  end
end
