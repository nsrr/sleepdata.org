class ChangeVariableIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :variables, :id, :bigint

    change_column :variable_forms, :variable_id, :bigint
    change_column :variable_labels, :variable_id, :bigint
  end

  def down
    change_column :variables, :id, :integer

    change_column :variable_forms, :variable_id, :integer
    change_column :variable_labels, :variable_id, :integer
  end
end
