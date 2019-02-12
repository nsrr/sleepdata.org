class ChangeAgreementEventTagIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :agreement_event_tags, :id, :bigint
  end

  def down
    change_column :agreement_event_tags, :id, :integer
  end
end
