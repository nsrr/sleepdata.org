class AddReviewedToHostingRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :hosting_requests, :reviewed, :boolean, null: false, default: false
    add_index :hosting_requests, :reviewed
  end
end
