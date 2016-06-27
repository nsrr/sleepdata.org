class AddDataDictionaryRepositoryToDatasets < ActiveRecord::Migration[4.2]
  def change
    add_column :datasets, :data_dictionary_repository, :string
  end
end
