class AddDulyAuthorizedRepresentativeTitleToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :duly_authorized_representative_title, :string
  end
end
