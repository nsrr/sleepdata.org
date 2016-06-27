class AddStatsToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :stats_n, :integer
    add_column :variables, :stats_mean, :float
    add_column :variables, :stats_stddev, :float
    add_column :variables, :stats_median, :float
    add_column :variables, :stats_min, :float
    add_column :variables, :stats_max, :float
    add_column :variables, :stats_unknown, :integer
    add_column :variables, :stats_total, :integer
  end
end
