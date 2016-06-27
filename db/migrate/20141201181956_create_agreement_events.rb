class CreateAgreementEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :agreement_events do |t|
      t.integer :agreement_id
      t.integer :user_id
      t.text :comment
      t.string :event_type
      t.datetime :event_at, null: false
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :agreement_events, :agreement_id
    add_index :agreement_events, :user_id
  end
end
