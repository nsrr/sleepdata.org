class ChangeDefaultStatusForAgreements < ActiveRecord::Migration
  def up
    change_column :agreements, :status, :string, null: false, default: 'started'
  end

  def down
    change_column :agreements, :status, :string, null: true, default: nil
  end
end
