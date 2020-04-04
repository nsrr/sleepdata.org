class RemoveStringLimitsFromVariables < ActiveRecord::Migration[6.0]
  def up
    change_column :variables, :name, :string, limit: nil
    change_column :variables, :display_name, :string, limit: nil
    change_column :variables, :variable_type, :string, limit: nil
    change_column :variables, :units, :string, limit: nil
    change_column :variables, :version, :string, limit: nil
    change_column :variables, :calculation, :string, limit: nil
  end

  def down
    change_column :variables, :name, :string, limit: 255
    change_column :variables, :display_name, :string, limit: 255
    change_column :variables, :variable_type, :string, limit: 255
    change_column :variables, :units, :string, limit: 255
    change_column :variables, :version, :string, limit: 255
    change_column :variables, :calculation, :string, limit: 255
  end
end
