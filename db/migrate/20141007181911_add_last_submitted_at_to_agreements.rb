class AddLastSubmittedAtToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :last_submitted_at, :datetime
  end
end
