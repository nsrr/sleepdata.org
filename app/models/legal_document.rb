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
  scope :published, -> { joins(:final_legal_documents).distinct }

  # Validations
  validates :name, presence: true
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ },
                   exclusion: { in: %w(new edit create update destroy) },
                   uniqueness: { scope: :organization_id },
                   allow_nil: true

  # Relationships
  belongs_to :organization
  has_many :legal_document_pages, -> { order(:position) }
  has_many :legal_document_variables, -> { current }
  has_many :legal_document_variable_options, -> { order(:legal_document_variable_id, :position) }
  has_many :legal_document_datasets
  has_many :datasets, through: :legal_document_datasets
  has_many :final_legal_documents, -> { current }

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

  def publish!
    final = final_legal_documents.create(
      organization_id: organization_id,
      name: name,
      slug: slug,
      commercial_type: commercial_type,
      data_user_type: data_user_type,
      attestation_type: attestation_type,
      approval_process: approval_process
    )
    legal_document_pages.each_with_index do |page, index|
      final_page = final.final_legal_document_pages.create(
        position: index + 1,
        rider: page.rider,
        title: page.title
      )
      final_page.update(content: page.readable_content)
    end
    legal_document_variables.each do |variable|
      final_variable = final.final_legal_document_variables.find_by(name: variable.name)
      next unless final_variable
      final_variable.update(
        name: variable.name,
        display_name: variable.display_name,
        variable_type: variable.variable_type,
        description: variable.description,
        field_note: variable.field_note,
        required: variable.required
      )
      variable.options.each do |option|
        final_variable.options.create(
          final_legal_document: final,
          position: option.position,
          display_name: option.display_name,
          value: option.value
        )
      end
    end
    final.finalize_version!
    final.update(published_at: Time.zone.now)
  end

  # def current_version
  #   latest = current_final_legal_document
  #   if latest
  #     [latest.version_major, latest.version_minor, latest.version_tiny]
  #   else
  #     [0, 0, 0]
  #   end
  # end

  def current_final_legal_document
    final_legal_documents.where.not(published_at: nil).order(published_at: :desc).limit(1).first
  end
end
