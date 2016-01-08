class AddSpoutStatsToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :spout_stats, :text
  end
end
