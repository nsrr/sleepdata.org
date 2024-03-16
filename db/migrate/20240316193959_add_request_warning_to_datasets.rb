class AddRequestWarningToDatasets < ActiveRecord::Migration[6.1]
  def change
    add_column :datasets, :request_warning, :text
  end
end
