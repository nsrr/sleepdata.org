class AddSecuredDeviceToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :secured_device, :boolean, null: false, default: false
  end
end
