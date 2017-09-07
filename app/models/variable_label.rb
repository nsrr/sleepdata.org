# frozen_string_literal: true

# Lists tags added or remove on a tag update event.
class VariableLabel < ApplicationRecord
  # Validations
  validates :variable_id, :name, presence: true
  validates :name, uniqueness: { scope: :variable_id, case_sensitive: false }

  # Relationships
  belongs_to :variable
end
