class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  # Concerns
  include Deletable, TokenAuthenticatable

  # Callbacks
  before_save :ensure_authentication_token

  # Named Scopes
  scope :aug_members, -> { current.where(aug_member: true) }
  scope :core_members, -> { current.where(core_member: true) }
  scope :system_admins, -> { current.where(system_admin: true) }
  scope :search, -> (arg) { where('LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')) }
  scope :with_name, -> (arg) { where("(users.first_name || ' ' || users.last_name) IN (?) or users.username IN (?)", arg, arg) }

  def self.aug_or_core_members
    current.where('aug_member = ? or core_member = ?', true, true)
  end

  def self.regular_members
    current.where(aug_member: false, core_member: false)
  end

  # Model Validation
  validates :first_name, :last_name, presence: true
  validates :username, uniqueness: { case_sensitive: false }, format: { with: /\A[a-z]\w*\Z/i }, allow_blank: true

  # Model Relationships
  has_many :agreements, -> { where deleted: false }
  has_many :agreement_events
  has_many :answers
  has_many :broadcasts, -> { current }
  has_many :challenges, -> { where deleted: false }
  has_many :comments, -> { where deleted: false }
  has_many :community_tools, -> { current }
  has_many :datasets, -> { where deleted: false }
  has_many :dataset_file_audits
  has_many :hosting_requests, -> { current }
  has_many :images
  has_many :reviews
  has_many :tags, -> { where deleted: false }
  has_many :tools
  has_many :topics, -> { where deleted: false }
  has_many :subscriptions

  # User Methods

  def all_topics
    if system_admin?
      Topic.current
    else
      topics
    end
  end

  def all_comments
    if system_admin?
      Comment.current
    else
      comments
    end
  end

  def all_agreements
    if system_admin?
      Agreement.current
    else
      agreements
    end
  end

  def all_agreement_events
    if system_admin?
      AgreementEvent.all
    else
      agreement_events
    end
  end

  def reviewable_agreements
    Agreement.current.where('agreements.id IN (select requests.agreement_id from requests where requests.dataset_id IN (?))', all_reviewable_datasets.select(:id))
  end

  def all_datasets
    Dataset.current.with_editor(id)
  end

  def all_reviewable_datasets
    Dataset.current.with_reviewer(id)
  end

  def all_viewable_datasets
    Dataset.current.with_viewer_or_editor(id)
  end

  def all_viewable_challenges
    if system_admin?
      Challenge.current
    else
      Challenge.current.where(public: true)
    end
  end

  def all_challenges
    if system_admin?
      Challenge.current
    else
      challenges
    end
  end

  def all_tools
    Tool.current.with_editor(id)
  end

  def all_viewable_tools
    Tool.current.with_viewer_or_editor(id)
  end

  def avatar_url(size = 80, default = 'mm')
    gravatar_id = Digest::MD5.hexdigest(email.to_s.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?&s=#{size}&r=pg&d=#{default}"
  end

  def can_post_links?
    aug_member? || core_member?
  end

  def topics_created_in_last_day
    topics.where('created_at >= ?', Date.today - 1.day)
  end

  def max_topics
    if aug_member? || core_member?
      10
    else
      2
    end
  end

  def digest_reviews
    reviews.where(approved: nil).joins(:agreement).where('agreements.deleted = ? and agreements.status = ?', false, 'submitted').order('agreements.last_submitted_at DESC')
  end

  def name
    "#{first_name} #{last_name}"
  end

  def name_was
    "#{first_name_was} #{last_name_was}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def reverse_name_and_email
    "#{last_name}, #{first_name} - #{email}"
  end

  def initials
    "#{first_name.first.upcase}#{last_name.first.upcase}"
  end

  def id_and_auth_token
    "#{id}-#{authentication_token}"
  end

  def forum_name
    username.blank? ? name : username
  end

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super && !deleted?
  end

  def destroy
    super
    update_column :updated_at, Time.zone.now
  end
end
