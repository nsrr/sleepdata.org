class CreateExports < ActiveRecord::Migration[5.1]
  def change
    create_table :exports do |t|
      t.string :name
      t.string :zipped_file
      t.datetime :file_created_at
      t.bigint :file_size
      t.string :status, null: false, default: "started"
      t.text :details
      t.integer :user_id
      t.integer :organization_id
      t.boolean :deleted, null: false, default: false
      t.timestamps
      t.index :user_id
      t.index :organization_id
      t.index :file_size
      t.index :status
      t.index :deleted
    end
  end
end
