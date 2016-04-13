# frozen_string_literal: true

# Represents a single option for a domain
# class DomainOption < ApplicationRecord # TODO: Rails 5
class DomainOption < ActiveRecord::Base
  # Model Validation
  validates :domain_id, :display_name, :value, presence: true

  # Model Relationships
  belongs_to :domain

  # Model Methods
end
