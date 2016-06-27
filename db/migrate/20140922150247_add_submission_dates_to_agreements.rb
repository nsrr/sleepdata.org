class AddSubmissionDatesToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :submitted_at, :datetime
    add_column :agreements, :resubmitted_at, :datetime
  end
end
