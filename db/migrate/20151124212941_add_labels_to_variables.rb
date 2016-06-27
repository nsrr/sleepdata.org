class AddLabelsToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :labels, :text
  end
end
