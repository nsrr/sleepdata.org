class AddQuestionnairesOnlyToDatasets < ActiveRecord::Migration[6.1]
  def change
    add_column :datasets, :questionnaires_only, :boolean, null: false, default: false
    add_index :datasets, :questionnaires_only
  end
end
