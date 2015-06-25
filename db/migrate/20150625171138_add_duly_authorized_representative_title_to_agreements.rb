class AddDulyAuthorizedRepresentativeTitleToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :duly_authorized_representative_title, :string
  end
end
