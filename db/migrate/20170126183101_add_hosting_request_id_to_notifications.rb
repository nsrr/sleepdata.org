class AddHostingRequestIdToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :hosting_request_id, :integer
    add_index :notifications, :hosting_request_id
  end
end
