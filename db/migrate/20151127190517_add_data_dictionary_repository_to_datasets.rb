class AddDataDictionaryRepositoryToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :data_dictionary_repository, :string
  end
end
