class RemoveLabelsFromVariables < ActiveRecord::Migration
  def up
    remove_column :variables, :labels
  end

  def down
    add_column :variables, :labels, :text
  end
end
