class CreateDatasetPageAudits < ActiveRecord::Migration[4.2]
  def change
    create_table :dataset_page_audits do |t|
      t.integer :dataset_id
      t.integer :user_id
      t.text :page_path
      t.string :remote_ip

      t.timestamps
    end
  end
end
