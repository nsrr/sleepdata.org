class AddNotCoveredPersonOrLocatedInCountryOfConcern < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :not_covered_person_country_of_concern_attestation_at, :datetime
  end
end
