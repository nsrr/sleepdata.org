class AddLabelsToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :labels, :text
  end
end
