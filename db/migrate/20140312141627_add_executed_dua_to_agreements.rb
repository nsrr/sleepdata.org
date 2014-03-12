class AddExecutedDuaToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :executed_dua, :string
  end
end
