# frozen_string_literal: true

# Allows forum posts and agreements to be tagged.
class Tag < ApplicationRecord
  TYPE = [%w(Forum topic), %w(Review agreement)]

  # Concerns
  include Deletable
  include Searchable

  # Scopes
  scope :forum_tags, -> { current.where(tag_type: "topic") }
  scope :review_tags, -> { current.where(tag_type: "agreement") }

  # Validations
  validates :name, :color, :user_id, :tag_type, presence: true
  validates :name, uniqueness: { scope: [:deleted, :tag_type], case_sensitive: false }

  # Relationships
  belongs_to :user
  has_many :topic_tags
  has_many :topics, -> { current }, through: :topic_tags

  has_many :agreement_tags
  has_many :agreements, -> { current }, through: :agreement_tags

  has_many :agreement_events, -> { current }

  # Methods
  def self.searchable_attributes
    %w(name)
  end

  def type_name
    type = TYPE.find { |_name, value| value == tag_type }
    type ? type.first : ""
  end
end
