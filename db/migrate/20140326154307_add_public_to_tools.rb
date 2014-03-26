class AddPublicToTools < ActiveRecord::Migration
  def change
    add_column :tools, :public, :boolean, null: false, default: true
  end
end
