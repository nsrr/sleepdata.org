class AddHumanSubjectsProectionsTrainedToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :human_subjects_protections_trained, :boolean, null: false, default: false
  end
end
