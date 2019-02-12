class ChangeTagIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :tags, :id, :bigint

    change_column :agreement_event_tags, :tag_id, :bigint
    change_column :agreement_tags, :tag_id, :bigint
    change_column :topic_tags, :tag_id, :bigint
  end

  def down
    change_column :tags, :id, :integer

    change_column :agreement_event_tags, :tag_id, :integer
    change_column :agreement_tags, :tag_id, :integer
    change_column :topic_tags, :tag_id, :integer
  end
end
