class AddReviewerSignatureToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :reviewer_signature, :text
  end
end
