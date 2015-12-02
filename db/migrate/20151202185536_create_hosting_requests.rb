class CreateHostingRequests < ActiveRecord::Migration
  def change
    create_table :hosting_requests do |t|
      t.integer :user_id
      t.text :description
      t.string :institution_name
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :hosting_requests, :user_id
    add_index :hosting_requests, :deleted
  end
end
