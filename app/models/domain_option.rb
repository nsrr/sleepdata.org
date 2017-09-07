# frozen_string_literal: true

# Represents a single option for a domain.
class DomainOption < ApplicationRecord
  # Validations
  validates :domain_id, :display_name, :value, presence: true

  # Relationships
  belongs_to :domain

  # Methods
end
