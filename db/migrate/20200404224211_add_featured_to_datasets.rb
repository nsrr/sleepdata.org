class AddFeaturedToDatasets < ActiveRecord::Migration[6.0]
  def change
    add_column :datasets, :featured, :boolean, default: false, null: false
    add_index :datasets, :featured
  end
end
