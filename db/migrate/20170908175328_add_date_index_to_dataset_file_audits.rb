class AddDateIndexToDatasetFileAudits < ActiveRecord::Migration[5.1]
  def change
    add_index :dataset_file_audits, :created_at
  end
end
