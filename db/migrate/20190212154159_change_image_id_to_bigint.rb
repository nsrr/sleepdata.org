class ChangeImageIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :images, :id, :bigint
  end

  def down
    change_column :images, :id, :integer
  end
end
