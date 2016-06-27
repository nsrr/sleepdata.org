class AddDulyAuthorizedSignaturePrintToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :duly_authorized_representative_signature, :text
    add_column :agreements, :duly_authorized_representative_signature_print, :string
    add_column :agreements, :duly_authorized_representative_signature_date, :date
    add_column :agreements, :duly_authorized_representative_token, :string
    add_index  :agreements, :duly_authorized_representative_token, unique: true
  end
end
