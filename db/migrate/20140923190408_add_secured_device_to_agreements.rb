class AddSecuredDeviceToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :secured_device, :boolean, null: false, default: false
  end
end
