# frozen_string_literal: true

class ToolUser < ApplicationRecord
  # Relationships
  belongs_to :tool
  belongs_to :user
end
