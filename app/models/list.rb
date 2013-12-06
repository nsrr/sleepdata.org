class List < ActiveRecord::Base

  serialize :variable_ids, Array


  # List Methods

  def variables(current_user)
    viewable_datasets = if current_user
      current_user.all_viewable_datasets
    else
      Dataset.current.where( public: true )
    end
    Variable.where( dataset_id: viewable_datasets.pluck(:id), id: variable_ids ).order( :name )
  end

end
