# frozen_string_literal: true

class DatasetPageAudit < ApplicationRecord
  # Relationships
  belongs_to :dataset
  belongs_to :user
end
