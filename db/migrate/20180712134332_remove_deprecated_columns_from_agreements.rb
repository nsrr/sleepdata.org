class RemoveDeprecatedColumnsFromAgreements < ActiveRecord::Migration[5.2]
  def change
    remove_column :agreements, :dua, :string
    remove_column :agreements, :executed_dua, :string
    remove_column :agreements, :irb, :string
    remove_column :agreements, :evidence_of_irb_review, :boolean, null: false, default: false
    remove_column :agreements, :data_user, :string
    remove_column :agreements, :individual_institution_name, :string
    remove_column :agreements, :individual_title, :string
    remove_column :agreements, :individual_telephone, :string
    remove_column :agreements, :individual_fax, :string
    remove_column :agreements, :organization_business_name, :string
    remove_column :agreements, :organization_contact_name, :string
    remove_column :agreements, :organization_contact_title, :string
    remove_column :agreements, :organization_contact_telephone, :string
    remove_column :agreements, :organization_contact_fax, :string
    remove_column :agreements, :organization_contact_email, :string
    remove_column :agreements, :individual_address, :text
    remove_column :agreements, :organization_address, :text
    remove_column :agreements, :specific_purpose, :text
    remove_column :agreements, :has_read_step3, :boolean, null: false, default: false
    remove_column :agreements, :posting_permission, :string
    remove_column :agreements, :has_read_step5, :boolean, null: false, default: false
    remove_column :agreements, :title_of_project, :string
    remove_column :agreements, :intended_use_of_data, :text
    remove_column :agreements, :data_secured_location, :text
    remove_column :agreements, :organization_emails, :text
    remove_column :agreements, :secured_device, :boolean, null: false, default: false
    remove_column :agreements, :human_subjects_protections_trained, :boolean, null: false, default: false
    remove_column :agreements, :unauthorized_to_sign, :boolean, null: false, default: false
  end
end
