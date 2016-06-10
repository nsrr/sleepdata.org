# frozen_string_literal: true

# Lists tags added or remove on a tag update event.
class VariableLabel < ApplicationRecord
  # Model Validation
  validates :variable_id, :name, presence: true
  validates :name, uniqueness: { scope: :variable_id, case_sensitive: false }

  # Model Relationships
  belongs_to :variable
end
