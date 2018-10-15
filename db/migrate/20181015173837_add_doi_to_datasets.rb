class AddDoiToDatasets < ActiveRecord::Migration[5.2]
  def change
    add_column :datasets, :doi, :string
  end
end
