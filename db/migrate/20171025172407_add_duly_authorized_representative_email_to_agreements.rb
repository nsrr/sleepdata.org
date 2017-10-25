class AddDulyAuthorizedRepresentativeEmailToAgreements < ActiveRecord::Migration[5.1]
  def change
    add_column :agreements, :duly_authorized_representative_email, :string
    add_column :agreements, :duly_authorized_representative_emailed_at, :datetime
    add_column :agreements, :duly_authorized_representative_signed_at, :datetime
  end
end
