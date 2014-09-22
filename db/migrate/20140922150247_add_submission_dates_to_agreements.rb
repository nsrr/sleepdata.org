class AddSubmissionDatesToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :submitted_at, :datetime
    add_column :agreements, :resubmitted_at, :datetime
  end
end
