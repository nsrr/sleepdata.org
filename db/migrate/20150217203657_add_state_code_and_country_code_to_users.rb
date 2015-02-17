class AddStateCodeAndCountryCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :state_code, :string
    add_column :users, :country_code, :string
  end
end
