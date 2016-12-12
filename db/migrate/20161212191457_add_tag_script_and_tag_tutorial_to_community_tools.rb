class AddTagScriptAndTagTutorialToCommunityTools < ActiveRecord::Migration[5.0]
  def change
    add_column :community_tools, :tag_script, :boolean, null: false, default: false
    add_column :community_tools, :tag_tutorial, :boolean, null: false, default: false
    add_index :community_tools, :tag_script
    add_index :community_tools, :tag_tutorial
  end
end
