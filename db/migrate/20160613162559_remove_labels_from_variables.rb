class RemoveLabelsFromVariables < ActiveRecord::Migration[4.2]
  def up
    remove_column :variables, :labels
  end

  def down
    add_column :variables, :labels, :text
  end
end
