# frozen_string_literal: true

class VariableForm < ActiveRecord::Base

  # Model Relationships
  belongs_to :dataset
  belongs_to :variable
  belongs_to :form

end
