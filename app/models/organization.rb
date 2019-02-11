# frozen_string_literal: true

# Groups datasets, data request templates, and reviewers.
class Organization < ApplicationRecord
  # Concerns
  include Deletable
  include Searchable
  include Sluggable

  # Scopes
  scope :with_editor, ->(arg) do
    joins(:organization_users).merge(
      OrganizationUser.where(user: arg, editor: true)
    )
  end

  scope :with_viewer, ->(arg) do
    joins(:organization_users).merge(OrganizationUser.where(user: arg))
  end

  scope :with_principal_reviewer, ->(arg) do
    joins(:organization_users).merge(
      OrganizationUser.where(user: arg, review_role: "principal")
    )
  end

  scope :with_reviewer, ->(arg) do
    joins(:organization_users).merge(
      OrganizationUser.where(user: arg, review_role: ["regular", "principal"])
    )
  end

  # Validations
  validates :name, presence: true
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ },
                   uniqueness: true,
                   allow_nil: true

  # Relationships
  has_many :datasets, -> { current }
  has_many :legal_documents, -> { current }
  has_many :legal_document_datasets
  has_many :final_legal_documents
  has_many :exports, -> { current }
  has_many :organization_users
  has_many :editors,
           -> { current.where(organization_users: { editor: true }) },
           source: :user, through: :organization_users
  # Viewers include editors and viewers.
  has_many :viewers,
           -> { current },
           source: :user, through: :organization_users
  has_many :reviewers,
           -> { current.where(organization_users: { review_role: ["regular", "principal"] }) },
           source: :user, through: :organization_users
  has_many :principal_reviewers,
           -> { current.where(organization_users: { review_role: "principal" }) },
           source: :user, through: :organization_users
  has_many :regular_reviewers,
           -> { current.where(organization_users: { review_role: "regular" }) },
           source: :user, through: :organization_users

  # Methods
  def self.searchable_attributes
    %w(name)
  end

  def destroy
    update slug: nil
    super
  end

  def data_requests
    DataRequest.current.joins(:final_legal_document).merge(final_legal_documents).distinct
  end

  def data_request_events
    AgreementEvent
      .with_current_agreement
      .joins(agreement: :final_legal_document)
      .where(agreements: { final_legal_documents: { organization: self } })
  end

  def editor?(current_user)
    return false unless current_user

    editors.where(id: current_user).count == 1
  end

  # Viewers include editors and viewers.
  def viewer?(current_user)
    return false unless current_user

    viewers.where(id: current_user).count == 1
  end

  def principal_reviewer?(current_user)
    return false unless current_user

    principal_reviewers.where(id: current_user).count == 1
  end
end
