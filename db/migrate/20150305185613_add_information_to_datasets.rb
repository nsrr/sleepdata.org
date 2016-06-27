class AddInformationToDatasets < ActiveRecord::Migration[4.2]
  def change
    add_column :datasets, :info_what, :string
    add_column :datasets, :info_who, :text
    add_column :datasets, :info_when, :string
    add_column :datasets, :info_funded_by, :text
    add_column :datasets, :info_citation, :text
    add_column :datasets, :info_size, :bigint, null: false, default: 0
  end
end
