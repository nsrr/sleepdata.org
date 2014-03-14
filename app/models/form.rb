class Form < ActiveRecord::Base

  # Model Validation
  validates_presence_of :name, :dataset_id
  validates_format_of :name, with: /\A[a-z]\w*\Z/i
  validates_uniqueness_of :name, scope: :dataset_id

  # Model Relationships
  belongs_to :dataset
  has_many :variable_forms
  has_many :variables

end
