class AddUrlToTools < ActiveRecord::Migration[4.2]
  def change
    add_column :tools, :url, :string
  end
end
