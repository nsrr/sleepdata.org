# frozen_string_literal: true

# Lists datasets added or remove on a dataset update event.
class AgreementEventDataset < ApplicationRecord
  # Validations
  validates :dataset_id, uniqueness: { scope: :agreement_event_id }

  # Relationships
  belongs_to :agreement_event
  belongs_to :dataset
end
