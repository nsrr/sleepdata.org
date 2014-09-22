class AddStepEightFieldsToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :title_of_project, :string
    add_column :agreements, :intended_use_of_data, :string
    add_column :agreements, :data_secured_location, :text
  end
end
