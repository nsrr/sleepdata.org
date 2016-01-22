# A broadcast is a blog post. Blog posts can be edited by community managers and
# set to be published on specific dates.
class Broadcast < ApplicationRecord
  # Concerns
  include Deletable

  # Named Scopes
  scope :published, -> { current.where(published: true).where('publish_date <= ?', Date.today) }

  # Model Validation
  validates :title, :description, :user_id, :publish_date, presence: true

  # Model Relationships
  belongs_to :user

  # Model Methods

  def to_param
    "#{id}-#{title.parameterize}"
  end
end
