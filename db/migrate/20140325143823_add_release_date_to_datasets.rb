class AddReleaseDateToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :release_date, :date
  end
end
