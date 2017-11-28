# frozen_string_literal: true

# A published and versioned legal document. Not editable.
class FinalLegalDocument < ApplicationRecord
  # Concerns
  include Deletable
  include Sluggable

  # Validations
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ },
                   exclusion: { in: %w(new edit create update destroy) },
                   allow_nil: true
  validates :version_build, format: { with: /\A[a-z0-9\-]*\Z/ }, allow_nil: true
  validates :version_md5, format: { with: /\A[a-f0-9]*\Z/ }, allow_nil: true

  # Relationships
  belongs_to :organization
  belongs_to :legal_document
  has_many :data_requests, -> { current }
  has_many :final_legal_document_pages, -> { order(:position) }
  has_many :final_legal_document_variables, -> { current }
  has_many :final_legal_document_variable_options, -> { order(:final_legal_document_variable_id, :position) }

  alias_method :legal_document_pages, :final_legal_document_pages
  alias_method :legal_document_variables, :final_legal_document_variables

  # Methods
  def attestation_name
    attestation_type == "signature" ? "Signature" : "Attest"
  end

  def finalize_version!
    compute_version!
    compute_md5!
  end

  # Major: If number of pages or variables changes, or the text changes.
  # Minor: If typos are fixed in text.
  # Tiny: If styling of text changes.
  def compute_version!
    build = nil
    latest = legal_document.current_final_legal_document
    if latest
      (major, minor, tiny) = [latest.version_major, latest.version_minor, latest.version_tiny]
      if major_change?(latest)
        major += 1
        minor = 0
        tiny = 0
      elsif minor_change?(latest)
        minor += 1
        tiny = 0
      else
        tiny += 1
      end
    else
      (major, minor, tiny) = [1, 0, 0]
    end
    update version_major: major, version_minor: minor, version_tiny: tiny, version_build: build
  end

  # Major: If number of pages or variables changes, or the text changes.
  def major_change?(latest)
    latest.major_content != major_content
  end

  def major_content
    final_legal_document_pages.collect(&:readable_content_for_major_comparison).join
  end

  # Minor: If typos are fixed in text.
  def minor_change?(latest)
    latest.minor_content != minor_content
  end

  def minor_content
    final_legal_document_pages.collect(&:readable_content_for_minor_comparison).join
  end

  # Pulls text of variables, pages, and document, and computes hexdigest.
  def compute_md5!
    strings = []
    strings += final_legal_document_variable_options.collect do |o|
      [
        o.position,
        o.display_name,
        o.value
      ].join
    end
    strings += final_legal_document_variables.collect do |v|
      [
        v.position,
        v.name,
        v.display_name,
        v.variable_type,
        v.description,
        v.field_note,
        v.required
      ].join
    end
    strings += final_legal_document_pages.collect do |p|
      [
        p.position,
        p.rider,
        p.title,
        p.content
      ].join
    end
    strings << name
    strings << slug
    strings << commercial_type
    strings << data_user_type
    strings << attestation_type
    strings << approval_process
    md5 = Digest::MD5.hexdigest(strings.join)
    update version_md5: md5
  end

  def version
    "v#{[version_major, version_minor, version_tiny].join(".")}"
  end

  def full_version
    [version_major, version_minor, version_tiny, version_md5].join(".")
  end

  def version_md5_short
    [version_major, version_minor, version_tiny, md5_short].join(".")
  end

  def md5_short
    version_md5.first(7)
  end
end
