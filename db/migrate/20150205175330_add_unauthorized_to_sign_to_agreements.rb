class AddUnauthorizedToSignToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :unauthorized_to_sign, :boolean, null: false, default: false
  end
end
