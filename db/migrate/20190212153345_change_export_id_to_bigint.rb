class ChangeExportIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :notifications, :export_id, :bigint
  end

  def down
    change_column :notifications, :export_id, :integer
  end
end
