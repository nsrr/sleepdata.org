class Tool < ActiveRecord::Base

  mount_uploader :logo, ImageUploader

  TYPE = [['Web', 'web'], ['Matlab', 'matlab'], ['R Language', 'r'], ['Java', 'java'], ['Utility', 'utility'], ['Ruby', 'ruby']].sort

  # Concerns
  include Deletable, Documentable, Gitable

  # Named Scopes
  scope :with_editor, lambda { |arg| where('tools.user_id IN (?) or tools.id in (select tool_users.tool_id from tool_users where tool_users.user_id = ? and tool_users.editor = ? and tool_users.approved = ?)', arg, arg, true, true ).references(:tool_users) }
  scope :with_viewer, lambda { |arg| where('tools.user_id IN (?) or tools.public = ? or tools.id in (select tool_users.tool_id from tool_users where tool_users.user_id = ? and tool_users.approved = ?)', arg, true, arg, true ).references(:tool_users) }

  # Model Validation
  validates_presence_of :name, :slug, :user_id
  validates_uniqueness_of :slug, scope: [ :deleted ]
  validates_format_of :slug, with: /\A[a-z][a-z0-9\-]*\Z/

  # Model Relationships
  belongs_to :user
  has_many :tool_users
  has_many :tool_contributors
  has_many :contributors, -> { where deleted: false }, through: :tool_contributors, source: :user

  # Tool Methods

  def to_param
    slug
  end

  def self.find_by_param(input)
    find_by_slug(input)
  end

  def viewers
    User.where( id: [self.user_id] + self.tool_users.where( approved: true ).pluck(:user_id) )
  end

  def editors
    User.where( id: [self.user_id] + self.tool_users.where( approved: true, editor: true ).pluck(:user_id) )
  end

  def root_folder
    File.join(CarrierWave::Uploader::Base.root, 'tools', (Rails.env.test? ? self.slug : self.id.to_s))
  end

  def create_page_audit!(current_user, page_path, remote_ip )
    # self.tool_page_audits.create( user_id: (current_user ? current_user.id : nil), page_path: page_path, remote_ip: remote_ip )
  end

  def type_name
    TYPE.select{|label, value| value == self.tool_type}.first[0] rescue nil
  end

end
