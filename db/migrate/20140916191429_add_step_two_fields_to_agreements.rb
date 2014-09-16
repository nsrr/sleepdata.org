class AddStepTwoFieldsToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :specific_purpose, :text
  end
end
