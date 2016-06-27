class AddGitRepositoryToDatasets < ActiveRecord::Migration[4.2]
  def change
    add_column :datasets, :git_repository, :string
  end
end
