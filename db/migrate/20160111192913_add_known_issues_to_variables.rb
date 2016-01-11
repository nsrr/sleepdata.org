class AddKnownIssuesToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :known_issues, :text
  end
end
