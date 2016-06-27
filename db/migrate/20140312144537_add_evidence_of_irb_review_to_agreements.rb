class AddEvidenceOfIrbReviewToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :evidence_of_irb_review, :boolean, null: false, default: false
  end
end
