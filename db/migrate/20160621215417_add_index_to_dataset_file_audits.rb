class AddIndexToDatasetFileAudits < ActiveRecord::Migration
  def change
    add_index :dataset_file_audits, :remote_ip
  end
end
