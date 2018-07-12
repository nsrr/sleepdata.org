class RemoveDeprecatedSignaturesFromAgreements < ActiveRecord::Migration[5.2]
  def change
    remove_column :agreements, :duly_authorized_representative_signature, :text
    remove_column :agreements, :reviewer_signature, :text
    remove_column :agreements, :signature, :text
  end
end
