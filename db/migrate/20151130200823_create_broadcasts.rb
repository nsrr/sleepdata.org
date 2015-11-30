class CreateBroadcasts < ActiveRecord::Migration
  def change
    create_table :broadcasts do |t|
      t.string :title
      t.text :description
      t.integer :user_id
      t.boolean :pinned, null: false, default: false
      t.boolean :archived, null: false, default: false
      t.string :image
      t.date :publish_date
      t.boolean :published, null: false, default: false
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :broadcasts, :archived
    add_index :broadcasts, :user_id
    add_index :broadcasts, :deleted
  end
end
