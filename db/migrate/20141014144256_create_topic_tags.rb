class CreateTopicTags < ActiveRecord::Migration
  def change
    create_table :topic_tags, id: false do |t|
      t.integer :topic_id
      t.integer :tag_id
    end

    add_index :topic_tags, :topic_id
    add_index :topic_tags, :tag_id
  end
end
