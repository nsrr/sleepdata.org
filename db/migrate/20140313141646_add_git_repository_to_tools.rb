class AddGitRepositoryToTools < ActiveRecord::Migration
  def change
    add_column :tools, :git_repository, :string
  end
end
