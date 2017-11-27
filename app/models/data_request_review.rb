# frozen_string_literal: true

# Represents a vote for or against a data request by a reviewer.
class DataRequestReview < ApplicationRecord
  # Relationships
  belongs_to :agreement
  belongs_to :user
end
