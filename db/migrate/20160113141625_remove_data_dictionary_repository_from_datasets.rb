class RemoveDataDictionaryRepositoryFromDatasets < ActiveRecord::Migration
  def change
    remove_column :datasets, :data_dictionary_repository, :string
  end
end
