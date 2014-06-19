class Subscription < ActiveRecord::Base

  # Model Validation
  validates_presence_of :topic_id, :user_id

  # Model Relationships
  belongs_to :topic
  belongs_to :user

end
