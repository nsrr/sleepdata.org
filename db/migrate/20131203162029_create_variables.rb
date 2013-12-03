class CreateVariables < ActiveRecord::Migration
  def change
    create_table :variables do |t|
      t.text :folder
      t.string :name
      t.string :display_name
      t.text :description
      t.string :variable_type
      t.integer :dataset_id
      t.integer :domain_id
      t.string :units
      t.string :version
      t.string :calculation
      t.boolean :commonly_used, null: false, default: false

      t.text :search_terms

      t.timestamps
    end

    add_index :variables, :dataset_id
    add_index :variables, :domain_id
  end
end
