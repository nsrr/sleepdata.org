class RemoveHistoryFromAgreements < ActiveRecord::Migration[4.2]
  def change
    remove_column :agreements, :history, :text
  end
end
