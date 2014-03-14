class CreateVariableForms < ActiveRecord::Migration
  def change
    create_table :variable_forms do |t|
      t.integer :variable_id
      t.integer :form_id
      t.integer :dataset_id
    end
    add_index :variable_forms, :variable_id
    add_index :variable_forms, :form_id
    add_index :variable_forms, :dataset_id
  end
end
