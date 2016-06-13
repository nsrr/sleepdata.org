class RemoveAddedAndRemovedTagIdsFromAgreementEvents < ActiveRecord::Migration
  def up
    remove_column :agreement_events, :added_tag_ids
    remove_column :agreement_events, :removed_tag_ids
  end

  def down
    add_column :agreement_events, :added_tag_ids, :text
    add_column :agreement_events, :removed_tag_ids, :text
  end
end
