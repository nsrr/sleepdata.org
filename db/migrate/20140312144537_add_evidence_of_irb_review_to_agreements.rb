class AddEvidenceOfIrbReviewToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :evidence_of_irb_review, :boolean, null: false, default: false
  end
end
