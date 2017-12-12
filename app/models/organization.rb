# frozen_string_literal: true

# Groups Datasets, DAUA Templates, and Reviewers.
class Organization < ApplicationRecord
  # Concerns
  include Deletable
  include Searchable
  include Sluggable

  # Validations
  validates :name, presence: true
  validates :slug, uniqueness: true
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ }

  # Relationships
  has_many :datasets, -> { current }
  has_many :legal_documents, -> { current }
  has_many :legal_document_datasets
  has_many :final_legal_documents

  # Methods
  def self.searchable_attributes
    %w(name)
  end

  def destroy
    update slug: nil
    super
  end

  def data_requests
    DataRequest.current.joins(:requests).merge(Request.where(dataset: datasets)).distinct
  end
end
