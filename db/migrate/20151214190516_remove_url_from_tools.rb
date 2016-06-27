class RemoveUrlFromTools < ActiveRecord::Migration[4.2]
  def change
    remove_column :tools, :url, :string
  end
end
