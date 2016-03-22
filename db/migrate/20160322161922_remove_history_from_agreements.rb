class RemoveHistoryFromAgreements < ActiveRecord::Migration
  def change
    remove_column :agreements, :history, :text
  end
end
