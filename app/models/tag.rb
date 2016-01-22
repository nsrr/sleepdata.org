class Tag < ApplicationRecord
  TYPE = [['Forum', 'topic'], ['Review', 'agreement']]

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, -> (arg) { where('LOWER(name) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%')) }
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

  def type_name
    types = TYPE.select { |_name, value| value == tag_type }
    types.size > 0 ? types.first[0] : ''
  end
end
