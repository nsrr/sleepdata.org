class Domain < ActiveRecord::Base
  serialize :options, Array

  # Model Validation
  validates_presence_of :name, :dataset_id
  validates_format_of :name, with: /\A[a-z]\w*\Z/i
  validates :name, length: { maximum: 30 }
  validates_uniqueness_of :name, scope: :dataset_id

  # Model Relationships
  belongs_to :dataset
  has_many :variables

  # Domain Methods
  def values
    self.options.collect{ |option| option[:value] }
  end
end
