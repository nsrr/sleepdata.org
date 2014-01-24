class AddToolTypeToTools < ActiveRecord::Migration
  def change
    add_column :tools, :tool_type, :string
  end
end
