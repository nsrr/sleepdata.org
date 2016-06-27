class AddExecutedDuaToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :executed_dua, :string
  end
end
