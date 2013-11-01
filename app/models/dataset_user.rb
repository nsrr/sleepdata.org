class DatasetUser < ActiveRecord::Base

  # Model Relationships
  belongs_to :dataset
  belongs_to :user

end
