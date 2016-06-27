class AddReleaseDateToDatasets < ActiveRecord::Migration[4.2]
  def change
    add_column :datasets, :release_date, :date
  end
end
