class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :title, :string
    add_column :users, :institution, :string
    add_column :users, :webpage, :string
    add_column :users, :research_summary, :text
  end
end
