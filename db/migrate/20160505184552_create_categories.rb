class CreateCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :slug
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :categories, :slug, unique: true
    add_index :categories, :deleted
    add_column :broadcasts, :category_id, :integer
    add_index :broadcasts, :category_id
  end
end
