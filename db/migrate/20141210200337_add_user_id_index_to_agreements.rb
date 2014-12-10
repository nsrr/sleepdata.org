class AddUserIdIndexToAgreements < ActiveRecord::Migration
  def change
    add_index :agreements, :user_id
  end
end
