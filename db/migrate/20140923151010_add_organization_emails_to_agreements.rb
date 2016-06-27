class AddOrganizationEmailsToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :organization_emails, :text
  end
end
