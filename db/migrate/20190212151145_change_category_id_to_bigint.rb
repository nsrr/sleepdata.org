class ChangeCategoryIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :categories, :id, :bigint

    change_column :broadcasts, :category_id, :bigint
  end

  def down
    change_column :categories, :id, :integer

    change_column :broadcasts, :category_id, :integer
  end
end
