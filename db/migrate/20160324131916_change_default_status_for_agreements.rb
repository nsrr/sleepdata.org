class ChangeDefaultStatusForAgreements < ActiveRecord::Migration[4.2]
  def up
    change_column :agreements, :status, :string, null: false, default: 'started'
  end

  def down
    change_column :agreements, :status, :string, null: true, default: nil
  end
end
