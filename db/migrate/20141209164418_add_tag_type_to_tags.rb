class AddTagTypeToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :tag_type, :string
  end
end
