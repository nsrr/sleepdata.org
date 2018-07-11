class RemoveHostingRequestIdFromNotifications < ActiveRecord::Migration[5.2]
  def change
    remove_index :notifications, :hosting_request_id
    remove_column :notifications, :hosting_request_id, :integer
  end
end
