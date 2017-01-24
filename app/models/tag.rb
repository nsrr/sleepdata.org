# frozen_string_literal: true

# Allows forum posts and agreements to be tagged.
class Tag < ApplicationRecord
  TYPE = [%w(Forum topic), %w(Review agreement)]

  # Concerns
  include Deletable, Searchable

  # Named Scopes
  scope :forum_tags, -> { current.where(tag_type: 'topic') }
  scope :review_tags, -> { current.where(tag_type: 'agreement') }

  # Model Validation
  validates :name, :color, :user_id, :tag_type, presence: true
  validates :name, uniqueness: { scope: [:deleted, :tag_type], case_sensitive: false }

  # Model Relationships
  belongs_to :user
  has_many :topic_tags
  has_many :topics, -> { where deleted: false }, through: :topic_tags

  has_many :agreement_tags
  has_many :agreements, -> { where deleted: false }, through: :agreement_tags

  has_many :agreement_events, -> { where deleted: false }

  # Model Methods
  def self.searchable_attributes
    %w(name)
  end

  def type_name
    types = TYPE.select { |_name, value| value == tag_type }
    types.size > 0 ? types.first[0] : ''
  end
end
