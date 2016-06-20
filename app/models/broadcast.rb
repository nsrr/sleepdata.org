# frozen_string_literal: true

# A broadcast is a blog post. Blog posts can be edited by community managers and
# set to be published on specific dates.
class Broadcast < ActiveRecord::Base
  # Concerns
  include Deletable, Replyable
  include PgSearch
  multisearchable against: [:title, :short_description, :keywords, :description],
                  unless: :deleted?

  # Named Scopes
  scope :published, -> { current.where(published: true).where('publish_date <= ?', Time.zone.today) }

  # Model Validation
  validates :title, :slug, :description, :user_id, :publish_date, presence: true
  validates :slug, uniqueness: { scope: :deleted }
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ }

  # Model Relationships
  belongs_to :user
  belongs_to :category

  # Model Methods
  def destroy
    super
    update_pg_search_document
    replies.each(&:update_pg_search_document)
  end

  def to_param
    slug_was.to_s
  end

  def url_hash
    {
      year: publish_date.year,
      month: publish_date.strftime('%m'),
      slug: slug
    }
  end

  def editable_by?(current_user)
    current_user.editable_broadcasts.where(id: id).count == 1
  end

  def last_page
    # ((replies.where(reply_id: nil).count - 1) / Reply::REPLIES_PER_PAGE) + 1
    1
  end
end
