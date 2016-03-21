# frozen_string_literal: true

class Answer < ActiveRecord::Base
  # Model Validation
  validates :challenge_id, :question_id, :user_id, presence: true
  validates :user_id, uniqueness: { scope: [:challenge_id, :question_id] }

  # Model Relationships
  belongs_to :challenge
  belongs_to :question
  belongs_to :user
end
