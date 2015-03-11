class Answer < ActiveRecord::Base

  # Model Validation
  validates_presence_of :challenge_id, :question_id, :user_id

  # Model Relationships
  belongs_to :challenge
  has_many :answers

end
