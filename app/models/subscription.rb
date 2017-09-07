# frozen_string_literal: true

class Subscription < ApplicationRecord
  # Validations
  validates_presence_of :topic_id, :user_id

  # Relationships
  belongs_to :topic
  belongs_to :user
end
