class AddAuthorToTools < ActiveRecord::Migration
  def change
    add_column :tools, :author, :string
  end
end
