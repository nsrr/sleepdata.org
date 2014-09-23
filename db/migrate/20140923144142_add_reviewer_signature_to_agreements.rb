class AddReviewerSignatureToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :reviewer_signature, :text
  end
end
