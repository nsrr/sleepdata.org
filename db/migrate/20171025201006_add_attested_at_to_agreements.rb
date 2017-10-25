class AddAttestedAtToAgreements < ActiveRecord::Migration[5.1]
  def change
    add_column :agreements, :attested_at, :datetime
  end
end
