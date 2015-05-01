class Challenge < ActiveRecord::Base

  SIGNAL_MAP = [('A'..'R'), ('A'..'V'), ('A'..'P'), ('A'..'N'), ('A'..'P'),
                ('A'..'S'), ('A'..'M'), ('A'..'M'), ('A'..'P'), ('A'..'M'),
                ('A'..'O'), ('A'..'S'), ('A'..'Q'), ('A'..'P'), ('A'..'M'),
                ('A'..'R'), ('A'..'P'), ('A'..'J'), ('A'..'S'), ('A'..'L'),
                ('A'..'M'), ('A'..'P'), ('A'..'M'), ('A'..'K'), ('A'..'M'),
                ('A'..'U'), ('A'..'O'), ('A'..'O'), ('A'..'L'), ('A'..'N')]

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :slug, :user_id
  validates_uniqueness_of :slug, scope: [ :deleted ]
  validates_format_of :slug, with: /\A[a-z][a-z0-9\-]*\Z/

  # Model Relationships
  belongs_to :user
  has_many :questions, -> { where deleted: false }
  has_many :answers

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
