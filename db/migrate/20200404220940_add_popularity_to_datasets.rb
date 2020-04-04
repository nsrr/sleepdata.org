class AddPopularityToDatasets < ActiveRecord::Migration[6.0]
  def change
    add_column :datasets, :popularity, :integer, default: 0, null: false
  end
end
