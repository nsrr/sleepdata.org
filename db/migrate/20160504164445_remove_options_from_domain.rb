class RemoveOptionsFromDomain < ActiveRecord::Migration[4.2]
  def change
    remove_column :domains, :options, :text
  end
end
