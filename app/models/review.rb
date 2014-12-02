class Review < ActiveRecord::Base

  # Model Validation
  validates_presence_of :agreement_id, :user_id

  # Model Relationships
  belongs_to :agreement
  belongs_to :user

end
