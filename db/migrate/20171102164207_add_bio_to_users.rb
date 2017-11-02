class AddBioToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :profile_bio, :string
    add_column :users, :profile_location, :string
    add_column :users, :profile_url, :string
  end
end
