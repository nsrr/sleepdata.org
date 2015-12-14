class RemoveUrlFromTools < ActiveRecord::Migration
  def change
    remove_column :tools, :url, :string
  end
end
