class AddTagIdsToAgreementEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :agreement_events, :added_tag_ids, :text
    add_column :agreement_events, :removed_tag_ids, :text
  end
end
