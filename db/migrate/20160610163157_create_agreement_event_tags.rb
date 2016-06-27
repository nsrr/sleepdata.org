class CreateAgreementEventTags < ActiveRecord::Migration[4.2]
  def change
    create_table :agreement_event_tags do |t|
      t.integer :agreement_event_id
      t.integer :tag_id
      t.boolean :added, null: false, default: true

      t.timestamps null: false
    end

    add_index :agreement_event_tags, [:agreement_event_id, :tag_id], unique: true
  end
end
