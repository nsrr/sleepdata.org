class AddIndexToDatasetFileAudits < ActiveRecord::Migration[4.2]
  def change
    add_index :dataset_file_audits, :remote_ip
  end
end
