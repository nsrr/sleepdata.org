class AddRemoteIpToDatasetFileAudits < ActiveRecord::Migration[4.2]
  def change
    add_column :dataset_file_audits, :remote_ip, :string
  end
end
