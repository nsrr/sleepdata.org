class ChangeQuarterIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :quarter_months, :quarter_id, :bigint
  end

  def down
    change_column :quarter_months, :quarter_id, :integer
  end
end
