class AddKeywordsToBroadcasts < ActiveRecord::Migration[4.2]
  def change
    add_column :broadcasts, :keywords, :string
  end
end
