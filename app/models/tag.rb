class Tag < ActiveRecord::Base

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where("LOWER(name) LIKE ?", arg.to_s.downcase.gsub(/^| |$/, '%')) }

  # Model Validation
  validates_presence_of :name, :color, :user_id
  validates_uniqueness_of :name, scope: [:deleted]

  # Model Relationships
  belongs_to :user
  has_many :topic_tags
  has_many :topics, -> { where deleted: false }, through: :topic_tags

end
