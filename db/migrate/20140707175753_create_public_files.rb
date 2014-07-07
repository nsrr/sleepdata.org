class CreatePublicFiles < ActiveRecord::Migration
  def change
    create_table :public_files do |t|
      t.integer :dataset_id
      t.integer :user_id
      t.text :file_path

      t.timestamps
    end
  end
end
