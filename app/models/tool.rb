class Tool < ActiveRecord::Base

  mount_uploader :logo, ImageUploader

  TYPE = [['Web', 'web'], ['Matlab', 'matlab'], ['R Language', 'r'], ['Java', 'java'], ['Utility', 'utility']].sort

  # Concerns
  include Deletable, Documentable, Gitable

  # Named Scopes
  scope :with_editor, lambda { |arg| where( user_id: arg ) }

  # Model Validation
  validates_presence_of :name, :slug, :user_id
  validates_uniqueness_of :slug, scope: [ :deleted ]
  validates_format_of :slug, with: /\A[a-z][a-z0-9\-]*\Z/

  # Model Relationships
  belongs_to :user

  # Tool Methods

  def to_param
    slug
  end

  def self.find_by_param(input)
    find_by_slug(input)
  end

  def editors
    User.where( id: self.user_id )
  end

  def root_folder
    File.join(CarrierWave::Uploader::Base.root, 'tools', (Rails.env.test? ? self.slug : self.id.to_s))
  end

  def create_page_audit!(current_user, page_path, remote_ip )
    # self.tool_page_audits.create( user_id: (current_user ? current_user.id : nil), page_path: page_path, remote_ip: remote_ip )
  end

  def self.background_color(type)
    case type when 'web'
      '#D8FFB1'
    when 'matlab'
      '#FDC7A1'
    when 'r'
      '#FC9FA1'
    when 'java'
      '#FFFFA1'
    when 'utility'
      '#FFFFFF'
    end
  end

  def type_name
    TYPE.select{|label, value| value == self.tool_type}.first[0] rescue nil
  end

end
