class AddStepsToExports < ActiveRecord::Migration[5.1]
  def change
    add_column :exports, :completed_steps, :integer, null: false, default: 0
    add_column :exports, :total_steps, :integer, null: false, default: 0
  end
end
