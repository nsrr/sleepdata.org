class RemoveAuthorFromTools < ActiveRecord::Migration
  def change
    remove_column :tools, :author, :string
  end
end
