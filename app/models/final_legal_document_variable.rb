# frozen_string_literal: true

# A variable on a published and versioned legal document. Not editable.
class FinalLegalDocumentVariable < ApplicationRecord
  # Concerns
  include Deletable

  # Validations
  validates :name, :variable_type, presence: true
  validates :name,
            format: { with: /\A[a-z]\w*\Z/i },
            length: { maximum: 32 },
            exclusion: { in: %w(new edit create update destroy overlap null) }
  validates :variable_type, inclusion: { in: LegalDocumentVariable::VARIABLE_TYPES.collect(&:second) }

  # Relationships
  belongs_to :final_legal_document

  # Methods

  def display_name_label
    display_name.present? ? display_name : name.titleize
  end
end
