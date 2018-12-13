class ChangeDatasetFileAuditsIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :dataset_file_audits, :id, :bigint
  end

  def down
    change_column :dataset_file_audits, :id, :integer
  end
end
