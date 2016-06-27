class CreateDatasetFileAudits < ActiveRecord::Migration[4.2]
  def change
    create_table :dataset_file_audits do |t|
      t.integer :dataset_id
      t.integer :user_id
      t.text :file_path
      t.integer :file_size, limit: 8
      t.string :medium

      t.timestamps
    end
  end
end
