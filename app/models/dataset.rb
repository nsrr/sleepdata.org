class Dataset < ActiveRecord::Base

  mount_uploader :logo, ImageUploader

  # Concerns
  include Deletable

  # Model Validation
  validates_presence_of :name, :slug, :user_id
  validates_uniqueness_of :slug, scope: [ :deleted ]
  validates_format_of :slug, with: /\A[a-z]\w*\Z/i

  # Model Relationships
  belongs_to :user

  def to_param
    slug
  end

  def self.find_by_param(input)
    find_by_slug(input)
  end

  def files
    Dir.glob("carrierwave/datasets/files/#{self.id}/*").collect{|f| [f.split('/').last, f]}
  end

  def editable_by?(current_user)
    @editable_by ||= begin
      current_user.all_datasets.where(id: self.id).count == 1
    end
  end

end
