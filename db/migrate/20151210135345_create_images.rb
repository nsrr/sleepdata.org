class CreateImages < ActiveRecord::Migration[4.2]
  def change
    create_table :images do |t|
      t.integer :user_id
      t.string :image
      t.integer :file_size, limit: 8

      t.timestamps null: false
    end

    add_index :images, :user_id
  end
end
