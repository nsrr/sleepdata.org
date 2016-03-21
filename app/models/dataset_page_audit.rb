# frozen_string_literal: true

class DatasetPageAudit < ApplicationRecord

  # Model Relationships
  belongs_to :dataset
  belongs_to :user

end
