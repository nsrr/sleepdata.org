class AddUnauthorizedToSignToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :unauthorized_to_sign, :boolean, null: false, default: false
  end
end
