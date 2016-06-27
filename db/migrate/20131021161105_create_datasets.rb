class CreateDatasets < ActiveRecord::Migration[4.2]
  def change
    create_table :datasets do |t|
      t.string :name
      t.text :description
      t.string :slug
      t.string :logo
      t.integer :user_id
      t.boolean :public, null: false, default: true
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end

    add_index :datasets, :public
    add_index :datasets, :slug, unique: true
  end
end
