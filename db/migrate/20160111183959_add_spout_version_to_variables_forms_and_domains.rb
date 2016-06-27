class AddSpoutVersionToVariablesFormsAndDomains < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :spout_version, :string
    add_column :forms, :spout_version, :string
    add_column :domains, :spout_version, :string
  end
end
