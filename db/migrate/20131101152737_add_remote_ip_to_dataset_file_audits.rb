class AddRemoteIpToDatasetFileAudits < ActiveRecord::Migration
  def change
    add_column :dataset_file_audits, :remote_ip, :string
  end
end
