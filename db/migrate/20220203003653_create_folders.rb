class CreateFolders < ActiveRecord::Migration[6.1]
  def change
    create_table :folders do |t|
      t.string :name
      t.string :slug
      t.boolean :displayed, null: false, default: true
      t.integer :position
      t.boolean :deleted, null: false, default: false
      t.timestamps

      t.index [:displayed, :position]
      t.index :slug, unique: true
      t.index :deleted
    end
  end
end
