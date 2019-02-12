class ChangeDatasetPageAuditIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :dataset_page_audits, :id, :bigint
  end

  def down
    change_column :dataset_page_audits, :id, :integer
  end
end
