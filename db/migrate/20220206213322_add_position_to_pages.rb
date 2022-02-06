class AddPositionToPages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :position, :integer
    add_index :pages, :position
  end
end
