class AddOrcididToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :orcidid, :string
  end
end
