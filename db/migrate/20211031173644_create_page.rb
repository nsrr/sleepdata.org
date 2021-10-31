class CreatePage < ActiveRecord::Migration[6.1]
  def change
    create_table :pages do |t|
      t.string :slug
      t.string :title
      t.text :description
      t.boolean :deleted, null: false, default: false
      t.timestamps

      t.index :slug, unique: true
      t.index :deleted
    end
  end
end
