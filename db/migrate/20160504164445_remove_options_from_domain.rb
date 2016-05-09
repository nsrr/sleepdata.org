class RemoveOptionsFromDomain < ActiveRecord::Migration
  def change
    remove_column :domains, :options, :text
  end
end
