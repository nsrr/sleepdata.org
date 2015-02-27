class Challenge < ActiveRecord::Base

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :slug, :user_id
  validates_uniqueness_of :slug, scope: [ :deleted ]
  validates_format_of :slug, with: /\A[a-z][a-z0-9\-]*\Z/

  # Model Relationships
  belongs_to :user

  # Challenge Methods

  def to_param
    slug
  end

  def root_folder
    File.join(CarrierWave::Uploader::Base.root, 'challenges', (Rails.env.test? ? self.slug : self.id.to_s))
  end

  def images_folder
    File.join( root_folder, 'images' )
  end


end
