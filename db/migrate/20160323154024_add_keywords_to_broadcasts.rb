class AddKeywordsToBroadcasts < ActiveRecord::Migration
  def change
    add_column :broadcasts, :keywords, :string
  end
end
