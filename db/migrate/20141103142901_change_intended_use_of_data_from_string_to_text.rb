class ChangeIntendedUseOfDataFromStringToText < ActiveRecord::Migration[4.2]
  def up
    change_column :agreements, :intended_use_of_data, :text
  end

  def down
    change_column :agreements, :intended_use_of_data, :string
  end
end
