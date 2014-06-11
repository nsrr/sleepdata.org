class Comment < ActiveRecord::Base

  # Concerns
  include Deletable

  # Model Validation
  validates_presence_of :topic_id, :description, :user_id

  # Model Relationships
  belongs_to :topic
  belongs_to :user

end
