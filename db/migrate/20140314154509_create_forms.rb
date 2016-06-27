class CreateForms < ActiveRecord::Migration[4.2]
  def change
    create_table :forms do |t|
      t.text :folder
      t.string :name
      t.string :display_name
      t.string :code_book
      t.integer :dataset_id
      t.string :version

      t.timestamps
    end
    add_index :forms, :dataset_id
  end
end
