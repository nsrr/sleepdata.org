class AddGitRepositoryToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :git_repository, :string
  end
end
