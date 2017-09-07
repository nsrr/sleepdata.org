# frozen_string_literal: true

# Lists tags added or remove on a tag update event.
class AgreementEventTag < ApplicationRecord
  # Validations
  validates :agreement_event_id, :tag_id, presence: true
  validates :tag_id, uniqueness: { scope: :agreement_event_id }

  # Relationships
  belongs_to :agreement_event
  belongs_to :tag
end
