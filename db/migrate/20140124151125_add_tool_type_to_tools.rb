class AddToolTypeToTools < ActiveRecord::Migration[4.2]
  def change
    add_column :tools, :tool_type, :string
  end
end
