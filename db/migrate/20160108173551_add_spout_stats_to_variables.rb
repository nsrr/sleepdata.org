class AddSpoutStatsToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :spout_stats, :text
  end
end
