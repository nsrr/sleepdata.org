class List < ActiveRecord::Base

  serialize :variable_ids, Array


  # List Methods

  # def self.find_list_for_user(current_user, list_id)
  #   list = List.find_by_id( list_id )
  #   list = current_user.lists.order( :id ).last if list == nil and current_user
  #   list
  # end

  def variables(current_user)
    viewable_datasets = if current_user
      current_user.all_viewable_datasets
    else
      Dataset.current.where( public: true )
    end
    new_variable_ids = []
    variable_ids.each do |dataset_id, variable_name|
      v = Variable.where( dataset_id: dataset_id, name: variable_name ).first
      new_variable_ids << v.id if v
    end
    Variable.where( dataset_id: viewable_datasets.pluck(:id), id: new_variable_ids ).order( :name )
  end

end
