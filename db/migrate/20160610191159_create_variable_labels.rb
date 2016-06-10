class CreateVariableLabels < ActiveRecord::Migration
  def change
    create_table :variable_labels do |t|
      t.integer :variable_id
      t.string :name

      t.timestamps null: false
    end
    add_index :variable_labels, [:variable_id, :name], unique: true
  end
end
