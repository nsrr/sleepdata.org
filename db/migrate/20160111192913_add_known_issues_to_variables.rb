class AddKnownIssuesToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :known_issues, :text
  end
end
