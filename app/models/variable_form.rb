# frozen_string_literal: true

class VariableForm < ApplicationRecord

  # Model Relationships
  belongs_to :dataset
  belongs_to :variable
  belongs_to :form

end
