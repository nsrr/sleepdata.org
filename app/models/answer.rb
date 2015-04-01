class Answer < ActiveRecord::Base

  # Model Validation
  validates_presence_of :challenge_id, :question_id, :user_id
  validates_uniqueness_of :user_id, scope: [ :challenge_id, :question_id ]

  # Model Relationships
  belongs_to :challenge
  belongs_to :question
  belongs_to :user

end
