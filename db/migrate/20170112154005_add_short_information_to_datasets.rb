class AddShortInformationToDatasets < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :subjects, :integer, null: false, default: 0
    add_column :datasets, :age_min, :integer, null: false, default: 0
    add_column :datasets, :age_max, :integer, null: false, default: 100
    add_column :datasets, :time_frame, :string
    add_column :datasets, :phenotype, :boolean, null: false, default: true
    add_column :datasets, :polysomnography, :boolean, null: false, default: false
    add_column :datasets, :actigraphy, :boolean, null: false, default: false
    add_index :datasets, :subjects
    add_index :datasets, :age_min
    add_index :datasets, :age_max
    add_index :datasets, :phenotype
    add_index :datasets, :polysomnography
    add_index :datasets, :actigraphy
  end
end
