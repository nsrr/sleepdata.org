# frozen_string_literal: true

# Represents a single option for a domain
class DomainOption < ApplicationRecord
  # Model Validation
  validates :domain_id, :display_name, :value, presence: true

  # Model Relationships
  belongs_to :domain

  # Model Methods
end
