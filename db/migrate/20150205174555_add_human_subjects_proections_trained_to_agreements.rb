class AddHumanSubjectsProectionsTrainedToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :human_subjects_protections_trained, :boolean, null: false, default: false
  end
end
