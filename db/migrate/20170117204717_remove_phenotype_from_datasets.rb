class RemovePhenotypeFromDatasets < ActiveRecord::Migration[5.0]
  def change
    remove_index :datasets, :phenotype
    remove_column :datasets, :phenotype, :boolean, null: false, default: true
  end
end
