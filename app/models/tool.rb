class Tool < ActiveRecord::Base

  mount_uploader :logo, ImageUploader

  # Concerns
  include Deletable

  # Named Scopes
  scope :with_editor, lambda { |arg| where( user_id: arg ) }

  # Model Validation
  validates_presence_of :name, :slug, :user_id
  validates_uniqueness_of :slug, scope: [ :deleted ]
  validates_format_of :slug, with: /\A[a-z]\w*\Z/i

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

  def editable_by?(current_user)
    @editable_by ||= begin
      self.editors.pluck( :id ).include?(current_user.id)
    end
  end

  def root_folder
    File.join(CarrierWave::Uploader::Base.root, 'tools', (Rails.env.test? ? self.slug : self.id.to_s))
  end

end
