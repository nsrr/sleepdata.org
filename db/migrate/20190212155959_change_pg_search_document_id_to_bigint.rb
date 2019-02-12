class ChangePgSearchDocumentIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :pg_search_documents, :id, :bigint
  end

  def down
    change_column :pg_search_documents, :id, :integer
  end
end
