class AddPublicToTools < ActiveRecord::Migration[4.2]
  def change
    add_column :tools, :public, :boolean, null: false, default: true
  end
end
