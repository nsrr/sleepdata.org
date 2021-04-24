class AddSearchTermsToDatasetPages < ActiveRecord::Migration[6.1]
  def change
    add_column :dataset_pages, :search_terms, :text
  end
end
