# Represents the valid values and options for a variable
class Domain < ActiveRecord::Base
  serialize :options, Array

  # Model Validation
  validates :name, :dataset_id, presence: true
  validates :name, format: { with: /\A[a-z]\w*\Z/i }
  validates :name, length: { maximum: 30 }
  validates :name, uniqueness: { scope: :dataset_id }

  # Model Relationships
  belongs_to :dataset
  has_many :variables

  # Domain Methods
  def values
    options.collect { |option| option[:value] }
  end
end
