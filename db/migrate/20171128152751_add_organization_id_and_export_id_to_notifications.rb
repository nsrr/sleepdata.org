class AddOrganizationIdAndExportIdToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :notifications, :organization_id, :integer
    add_column :notifications, :export_id, :integer
    add_index :notifications, :organization_id
    add_index :notifications, :export_id
  end
end
