class CreateRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :requests do |t|
      t.integer :agreement_id
      t.integer :dataset_id

      t.timestamps null: false
    end
  end
end
