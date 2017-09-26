class AddSignatureFilesToAgreements < ActiveRecord::Migration[5.1]
  def change
    add_column :agreements, :signature_file, :string
    add_column :agreements, :duly_authorized_representative_signature_file, :string
    add_column :agreements, :reviewer_signature_file, :string
  end
end
