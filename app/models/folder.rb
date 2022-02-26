# frozen_string_literal: true

# Menu folders that group pages together.
class Folder < ApplicationRecord
  # Constants
  ORDERS = {
    "id desc" => "folders.id desc",
    "id" => "folders.id nulls last",
    "position" => "folders.position",
    "position desc" => "folders.position desc",
    "displayed desc" => "folders.displayed",
    "displayed" => "folders.displayed desc"
  }
  DEFAULT_ORDER = "folders.position nulls last"

  # Concerns
  include Deletable
  include Searchable
  include Sluggable

  # Validations
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ },
                   exclusion: { in: %w(new edit create update destroy) },
                   allow_nil: true

  # Scopes
  scope :displayed, -> { current.where(displayed: true) }
  scope :menu_left, -> { where("position < 0").order(:position) }
  scope :menu_right, -> { where("position >= 0").order(:position) }

  # Relationships
  has_many :pages, -> { current.order("position nulls last") }

  # Methods
  def self.searchable_attributes
    %w(slug name)
  end

  def destroy
    super
    update slug: nil
  end
end
