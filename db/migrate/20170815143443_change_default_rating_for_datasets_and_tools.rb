class ChangeDefaultRatingForDatasetsAndTools < ActiveRecord::Migration[5.1]
  def up
    change_column :datasets, :rating, :float, null: false, default: 3.0
    change_column :community_tools, :rating, :float, null: false, default: 3.0
  end

  def down
    change_column :datasets, :rating, :float, null: true, default: nil
    change_column :community_tools, :rating, :float, null: true, default: nil
  end
end
