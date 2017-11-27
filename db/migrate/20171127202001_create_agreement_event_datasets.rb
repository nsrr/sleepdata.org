class CreateAgreementEventDatasets < ActiveRecord::Migration[5.1]
  def change
    create_table :agreement_event_datasets do |t|
      t.integer :agreement_event_id
      t.integer :dataset_id
      t.boolean :added, null: false, default: true
      t.timestamps
      t.index [:agreement_event_id, :dataset_id], unique: true, name: "idx_agreement_event_id_and_dataset_id"
    end
  end
end
