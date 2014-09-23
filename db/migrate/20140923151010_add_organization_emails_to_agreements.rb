class AddOrganizationEmailsToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :organization_emails, :text
  end
end
