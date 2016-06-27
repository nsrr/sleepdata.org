class AddIndexToAudits < ActiveRecord::Migration[4.2]
  def change
    add_index :dataset_file_audits, :dataset_id
    add_index :dataset_file_audits, :user_id
    add_index :dataset_file_audits, [:dataset_id, :user_id]

    add_index :dataset_page_audits, :dataset_id
    add_index :dataset_page_audits, :user_id
    add_index :dataset_page_audits, :page_path
    add_index :dataset_page_audits, [:dataset_id, :page_path]
  end
end
