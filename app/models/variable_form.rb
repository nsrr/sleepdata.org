# frozen_string_literal: true

# Defines forms that include the variable.
class VariableForm < ApplicationRecord
  # Relationships
  belongs_to :dataset, optional: true
  belongs_to :variable
  belongs_to :form
end
