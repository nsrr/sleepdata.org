class AddStepOneFieldsToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :current_step, :integer, null: false, default: 0

    add_column :agreements, :data_user, :string
    add_column :agreements, :data_user_type, :string, null: false, default: 'individual'

    add_column :agreements, :individual_institution_name, :string
    add_column :agreements, :individual_title, :string
    add_column :agreements, :individual_telephone, :string
    add_column :agreements, :individual_fax, :string
    add_column :agreements, :individual_address, :text

    add_column :agreements, :organization_business_name, :string
    add_column :agreements, :organization_contact_name, :string
    add_column :agreements, :organization_contact_title, :string
    add_column :agreements, :organization_contact_telephone, :string
    add_column :agreements, :organization_contact_fax, :string
    add_column :agreements, :organization_contact_email, :string
    add_column :agreements, :organization_address, :text
  end
end
