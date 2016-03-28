class DropPublicFiles < ActiveRecord::Migration
  def change
    drop_table :public_files do |t|
      t.integer :dataset_id
      t.integer :user_id
      t.text :file_path
      t.timestamps null: false
    end
  end
end
