class RemoveAuthenticationsTable < ActiveRecord::Migration
  def change
    drop_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid

      t.timestamps null: true
    end
  end
end
