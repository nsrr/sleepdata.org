# Represents the PDF or CRF on which a variable was captured
class Form < ActiveRecord::Base
  # Model Validation
  validates :name, :dataset_id, :dataset_version_id, presence: true
  validates :name, format: { with: /\A[a-z]\w*\Z/i }
  validates :name, uniqueness: { scope: [:dataset_id, :dataset_version_id], case_sensitive: false }

  # Model Relationships
  belongs_to :dataset
  belongs_to :dataset_version
  has_many :variable_forms
  has_many :variables

  def pdf?
    extension == 'pdf'
  end

  def image?
    %w(png jpg jpeg gif).include?(extension)
  end

  def extension
    code_book.split('.').last.to_s.downcase
  end
end
