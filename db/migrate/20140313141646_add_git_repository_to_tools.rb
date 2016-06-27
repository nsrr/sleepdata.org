class AddGitRepositoryToTools < ActiveRecord::Migration[4.2]
  def change
    add_column :tools, :git_repository, :string
  end
end
