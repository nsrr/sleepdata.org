class ChangeRequestIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :requests, :id, :bigint
  end

  def down
    change_column :requests, :id, :integer
  end
end
