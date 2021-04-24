class CreateDatasetPages < ActiveRecord::Migration[6.1]
  def change
    create_table :dataset_pages do |t|
      t.bigint :dataset_id
      t.text :page_path
      t.text :contents
      t.timestamps

      t.index [:dataset_id, :page_path], unique: true
    end
  end
end
