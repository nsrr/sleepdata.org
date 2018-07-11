class DropHostingRequestsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :hosting_requests do |t|
      t.integer :user_id
      t.text :description
      t.string :institution_name
      t.boolean :deleted, null: false, default: false
      t.boolean :reviewed, null: false, default: false
      t.timestamps
      t.index :user_id
      t.index :deleted
      t.index :reviewed
    end
  end
end
