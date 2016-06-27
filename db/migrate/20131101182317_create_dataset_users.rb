class CreateDatasetUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :dataset_users do |t|
      t.integer :dataset_id
      t.integer :user_id
      t.boolean :editor, null: false, default: false
      t.boolean :approved

      t.timestamps
    end
  end
end
