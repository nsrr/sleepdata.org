class RemoveAuthorFromTools < ActiveRecord::Migration[4.2]
  def change
    remove_column :tools, :author, :string
  end
end
