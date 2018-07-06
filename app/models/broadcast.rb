# frozen_string_literal: true

# A broadcast is a blog post. Blog posts can be edited by community managers and
# set to be published on specific dates.
class Broadcast < ApplicationRecord
  # Concerns
  include Deletable
  include Replyable
  include Searchable
  include PgSearch
  multisearchable against: [:title, :short_description, :keywords, :description],
                  unless: :deleted?

  # Scopes
  scope :published, -> { current.where(published: true).where('publish_date <= ?', Time.zone.today) }

  # Validations
  validates :title, :slug, :description, :user_id, :publish_date, presence: true
  validates :slug, uniqueness: { scope: :deleted }
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ }

  # Relationships
  belongs_to :user
  belongs_to :category, optional: true

  # Methods
  def self.searchable_attributes
    %w(title short_description keywords description)
  end

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

  def auto_locked?
    false
  end

  def locked?
    false
  end

  def last_page
    # ((replies.where(reply_id: nil).count - 1) / Reply::REPLIES_PER_PAGE) + 1
    1
  end

  def subscribers
    User.none
  end

  # TODO: Refactor or remove into search module
  def self.compute_ranges(description_array, terms)
    cleaned_array = description_array.collect { |t| t.gsub(/[^\w]/, '').to_s.downcase }
    indices = cleaned_array.each_index.select { |i| cleaned_array[i].in?(terms) }
    @ranges = []
    indices.each do |index|
      @ranges << [[index - 4, 0].max, [index + 4, cleaned_array.count].min]
    end
    @ranges = merge_overlapping_ranges(@ranges)
    @ranges = [[0, 9]] if @ranges.empty?
    @ranges
  end

  def self.ranges_overlap?(a, b)
    a.last >= b.first
  end

  def self.merge_ranges(a, b)
    [[a.first, b.first].min, [a.last, b.last].max]
  end

  def self.merge_overlapping_ranges(ranges)
    ranges.sort_by(&:first).inject([]) do |inner_ranges, range|
      if !inner_ranges.empty? && ranges_overlap?(inner_ranges.last, range)
        inner_ranges[0...-1] + [merge_ranges(inner_ranges.last, range)]
      else
        inner_ranges + [range]
      end
    end
  end
end
