class AddDegreeToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :degree, :string
  end
end
