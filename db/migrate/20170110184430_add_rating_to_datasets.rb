class AddRatingToDatasets < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :rating, :float
    add_index :datasets, :rating
  end
end
