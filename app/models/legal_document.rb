# frozen_string_literal: true

# Defines an organization's legal document.
class LegalDocument < ApplicationRecord
  # Constants
  COMMERCIAL_TYPES = [
    ["Both", "both"],
    ["Noncommercial Only", "noncommercial"],
    ["Commercial Only", "commercial"]
  ]
  DATA_USER_TYPES = [
    ["Both", "both"],
    ["Individual", "individual"],
    ["Organization", "organization"]
  ]
  ATTESTATION_TYPES = [
    ["None", "none"],
    ["Checkbox", "checkbox"],
    ["Signature", "signature"]
  ]
  APPROVAL_PROCESS_TYPES = [
    ["Immediate", "immediate"],
    ["Committee", "committee"]
  ]

  # Concerns
  include Deletable
  include Searchable
  include Sluggable

  # Scopes
  scope :published, -> { current } # TODO: Don't allow "draft" legal docs

  # Validations
  validates :name, presence: true
  validates :slug, uniqueness: { scope: :organization_id }
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ }

  # Relationships
  belongs_to :organization
  has_many :legal_document_pages
  has_many :legal_document_variables, -> { current }
  has_many :legal_document_datasets
  has_many :datasets, through: :legal_document_datasets

  # Methods
  def self.searchable_attributes
    %w(name)
  end

  def destroy
    update slug: nil
    super
  end

  def commercial_type_name
    COMMERCIAL_TYPES.find { |_name, value| value == commercial_type }.first
  end

  def data_user_type_name
    DATA_USER_TYPES.find { |_name, value| value == data_user_type }.first
  end

  def attestation_type_name
    ATTESTATION_TYPES.find { |_name, value| value == attestation_type }.first
  end

  def approval_process_name
    APPROVAL_PROCESS_TYPES.find { |_name, value| value == approval_process }.first
  end
end
