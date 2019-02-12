class ChangeAgreementEventIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :agreement_events, :id, :bigint

    change_column :agreement_event_datasets, :agreement_event_id, :bigint
    change_column :agreement_event_tags, :agreement_event_id, :bigint
  end

  def down
    change_column :agreement_events, :id, :integer

    change_column :agreement_event_datasets, :agreement_event_id, :integer
    change_column :agreement_event_tags, :agreement_event_id, :integer
  end
end
