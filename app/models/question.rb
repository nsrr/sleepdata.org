# frozen_string_literal: true

class Question < ApplicationRecord
  # Validations
  validates :name, :challenge_id, presence: true
  validates :name, uniqueness: { scope: [:challenge_id, :deleted], case_sensitive: false }

  # Relationships
  belongs_to :challenge
  has_many :answers
end
