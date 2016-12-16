class AddTagProgramToCommunityTools < ActiveRecord::Migration[5.0]
  def change
    add_column :community_tools, :tag_program, :boolean, null: false, default: false
    add_index :community_tools, :tag_program
  end
end
