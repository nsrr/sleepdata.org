class Question < ActiveRecord::Base

  # Model Validation
  validates_presence_of :name, :challenge_id
  validates_uniqueness_of :name, scope: [ :challenge_id, :deleted ]

  # Model Relationships
  belongs_to :challenge
  has_many :answers

end
