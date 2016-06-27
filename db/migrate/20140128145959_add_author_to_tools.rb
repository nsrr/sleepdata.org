class AddAuthorToTools < ActiveRecord::Migration[4.2]
  def change
    add_column :tools, :author, :string
  end
end
