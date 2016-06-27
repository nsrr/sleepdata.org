class AddUserIdIndexToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_index :agreements, :user_id
  end
end
