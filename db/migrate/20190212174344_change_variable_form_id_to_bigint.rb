class ChangeVariableFormIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :variable_forms, :id, :bigint
  end

  def down
    change_column :variable_forms, :id, :integer
  end
end
