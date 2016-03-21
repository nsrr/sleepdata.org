# frozen_string_literal: true

class ToolUser < ActiveRecord::Base

  # Model Relationships
  belongs_to :tool
  belongs_to :user

end
