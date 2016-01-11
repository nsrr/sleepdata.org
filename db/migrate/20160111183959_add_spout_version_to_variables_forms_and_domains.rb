class AddSpoutVersionToVariablesFormsAndDomains < ActiveRecord::Migration
  def change
    add_column :variables, :spout_version, :string
    add_column :forms, :spout_version, :string
    add_column :domains, :spout_version, :string
  end
end
