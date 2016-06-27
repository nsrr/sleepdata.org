class RemoveDataDictionaryRepositoryFromDatasets < ActiveRecord::Migration[4.2]
  def change
    remove_column :datasets, :data_dictionary_repository, :string
  end
end
