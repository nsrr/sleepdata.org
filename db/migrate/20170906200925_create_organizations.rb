class CreateOrganizations < ActiveRecord::Migration[5.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :slug
      t.boolean :deleted, null: false, default: false
      t.index :slug, unique: true
      t.index :deleted
      t.timestamps
    end
  end
end
