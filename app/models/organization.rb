# frozen_string_literal: true

# Groups Datasets, DAUA Templates, and Reviewers.
class Organization < ApplicationRecord
  # Concerns
  include Deletable
  include Searchable
  include Sluggable

  # Validations
  validates :name, :slug, presence: true
  validates :slug, uniqueness: { scope: :deleted }
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ }

  # Methods
  def self.searchable_attributes
    %w(name)
  end

  def destroy
    update slug: nil
    super
  end
end
