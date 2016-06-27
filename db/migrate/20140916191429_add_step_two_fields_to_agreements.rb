class AddStepTwoFieldsToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :specific_purpose, :text
  end
end
