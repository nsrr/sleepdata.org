class AddReviewerCommentToAgreementVariable < ActiveRecord::Migration[5.1]
  def change
    add_column :agreement_variables, :reviewer_comment, :string
    add_column :agreement_variables, :resubmission_required, :boolean, null: false, default: false
    add_index :agreement_variables, :resubmission_required
  end
end
