class Tag < ActiveRecord::Base

  TYPE = [['Forum', 'topic'], ['Review', 'agreement']]

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where("LOWER(name) LIKE ?", arg.to_s.downcase.gsub(/^| |$/, '%')) }
  scope :forum_tags, -> { current.where(tag_type: 'topic') }
  scope :review_tags, -> { current.where(tag_type: 'agreement') }

  # Model Validation
  validates_presence_of :name, :color, :user_id, :tag_type
  validates_uniqueness_of :name, scope: [:deleted, :tag_type]

  # Model Relationships
  belongs_to :user
  has_many :topic_tags
  has_many :topics, -> { where deleted: false }, through: :topic_tags

  has_many :agreement_tags
  has_many :agreements, -> { where deleted: false }, through: :agreement_tags

  has_many :agreement_events, -> { where deleted: false }

  def type_name
    types = TYPE.select{|name, value| value == self.tag_type}
    types.size > 0 ? types.first[0] : ""
  end

end
