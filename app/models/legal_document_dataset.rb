# frozen_string_literal: true

class LegalDocumentDataset < ApplicationRecord
  # Validations
  validates :dataset, uniqueness: { scope: :legal_document }

  # Relationships
  belongs_to :organization
  belongs_to :legal_document
  belongs_to :dataset

  # Methods
  def name
    "#{legal_document.name} - #{dataset.name}"
  end
end
