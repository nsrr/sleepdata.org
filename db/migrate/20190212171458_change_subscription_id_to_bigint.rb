class ChangeSubscriptionIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :subscriptions, :id, :bigint
  end

  def down
    change_column :subscriptions, :id, :integer
  end
end
