class ChangeVariableLabelIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :variable_labels, :id, :bigint
  end

  def down
    change_column :variable_labels, :id, :integer
  end
end
