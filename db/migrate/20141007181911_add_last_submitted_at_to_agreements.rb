class AddLastSubmittedAtToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :last_submitted_at, :datetime
  end
end
